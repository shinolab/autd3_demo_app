// File: main.cpp
// Project: server
// Created Date: 22/04/2023
// Author: Shun Suzuki
// -----
// Last Modified: 22/04/2023
// Modified By: Shun Suzuki (suzuki@hapis.k.u-tokyo.ac.jp)
// -----
// Copyright (c) 2023 Shun Suzuki. All rights reserved.
//

#include <arpa/inet.h>
#include <netinet/in.h>
#include <signal.h>
#include <stdio.h>
#include <string.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <unistd.h>

#include <iostream>
#include <memory>
#include <stdexcept>
#include <string>
#include <thread>
#include <utility>
#include <vector>

#include "autd3.hpp"
#include "autd3/link/soem.hpp"
#include "spdlog/spdlog.h"
#include "util.hpp"

namespace autd3demo {

class App {
 public:
  explicit App(int port = 50632) : _port(port) {}

  ~App() {
    try {
      close();
    } catch (std::exception& e) {
      spdlog::error("{}", e.what());
    }
  }

  void connect() {
    if (_th.joinable()) _th.join();
    if (_cnt != nullptr) {
      _cnt->close();
      _cnt = nullptr;
    }

    sockaddr_in addr{};
    sockaddr_in dst_addr{};

    _socket = socket(AF_INET, SOCK_STREAM, 0);
    if (_socket < 0) throw std::runtime_error("Cannot connect to client");

    constexpr int y = 1;
    setsockopt(_socket, SOL_SOCKET, SO_REUSEADDR, reinterpret_cast<const char*>(&y), sizeof y);

    addr.sin_family = AF_INET;
    addr.sin_port = htons(_port);
    addr.sin_addr.s_addr = htonl(INADDR_ANY);

    if (const auto e = bind(_socket, reinterpret_cast<sockaddr*>(&addr), sizeof addr); e != 0)
      throw std::runtime_error("Failed to bind sock: " + std::to_string(e));
    if (const auto e = listen(_socket, 1); e != 0) throw std::runtime_error("Failed to listen: " + std::to_string(e));

    spdlog::info("waiting connection...");

    socklen_t dst_addr_size = sizeof dst_addr;
    _dst_socket = accept(_socket, reinterpret_cast<sockaddr*>(&dst_addr), &dst_addr_size);
    if (_dst_socket < 0) throw std::runtime_error("Failed to connect client: ");
    if (errno != 0) throw std::runtime_error("Failed to connect client: " + std::string(strerror(errno)));

    u_long val = 1;
    ioctl(_dst_socket, FIONBIO, &val);

    _is_open = true;
    spdlog::info("connected...");
    spdlog::info("waiting command...");
    _th = std::thread([this]() {
      std::vector<char> buffer(4096);
      while (_is_open) {
        const auto len = recv(_dst_socket, buffer.data(), static_cast<int>(buffer.size()), 0);
        if (len <= 0) continue;
        std::string s(buffer.data(), static_cast<size_t>(len));
        spdlog::info(s);

        const auto tokens = split(s, '/');

        const auto cmd = tokens.size() > 0 ? tokens[0] : "e";
        std::string result = "ok";

        if (cmd == "close") {
          _is_open = false;
          if (_dst_socket != -1) {
            ::close(_dst_socket);
            _dst_socket = -1;
          }
          if (_socket != -1) {
            ::close(_socket);
            _socket = -1;
          }
          if (_cnt != nullptr) {
            _cnt->close();
            _cnt = nullptr;
          }
          return;
        } else if (cmd == "geo") {
          auto builder = autd3::Geometry::Builder().sound_speed(340.0e3);
          for (size_t i = 1; i < tokens.size(); i++) {
            const auto geo = split(tokens[i], ',');
            builder.add_device(
                autd3::AUTD3(autd3::Vector3(to_d(geo[0]), to_d(geo[1]), to_d(geo[2])), autd3::Vector3(to_a(geo[3]), to_a(geo[4]), to_a(geo[5]))));
          }
          auto geometry = builder.build();
          auto link = autd3::link::SOEM()
                          .on_lost([](const std::string& msg) {
                            std::cerr << "Link is lost\n";
                            std::cerr << msg;
                            std::quick_exit(-1);
                          })
                          .build();
          try {
            auto autd = autd3::Controller::open(std::move(geometry), std::move(link));
            _cnt = std::make_unique<autd3::Controller>(std::move(autd));

            _cnt->send(autd3::Clear());
            _cnt->send(autd3::Synchronize());

            autd3::modulation::Static m(1);
            _cnt->send(m);
          } catch (std::exception& e) {
            spdlog::warn("{}", e.what());
            result = "e";
          }
        } else if (cmd == "focus") {
          const auto data = split(tokens[1], ',');
          autd3::Vector3 p = _cnt->geometry().center() + autd3::Vector3(to_d(data[0]), to_d(data[1]), to_d(data[2]));
          const double amp = to_d(data[3]);
          spdlog::info("focus: ({}, {}, {}), {}", p.x(), p.y(), p.z(), amp);
          autd3::gain::Focus g(p, amp);
          _cnt->send(g);
        } else if (cmd == "bessel") {
          const auto data = split(tokens[1], ',');
          autd3::Vector3 p = _cnt->geometry().center() + autd3::Vector3(to_d(data[0]), to_d(data[1]), to_d(data[2]));
          autd3::Vector3 n = autd3::Vector3(to_d(data[3]), to_d(data[4]), to_d(data[5]));
          const double theta = to_a(data[6]);
          const double amp = to_d(data[7]);
          spdlog::info("bessel: ({}, {}, {}), ({}, {}, {}), {}, {}", p.x(), p.y(), p.z(), n.x(), n.y(), n.z(), theta, amp);
          autd3::gain::BesselBeam g(p, n, theta, amp);
          _cnt->send(g);
        } else if (cmd == "lm") {
          const auto data = split(tokens[1], ',');
          autd3::Vector3 c = _cnt->geometry().center() + autd3::Vector3(to_d(data[0]), to_d(data[1]), to_d(data[2]));
          const double freq = to_d(data[3]);
          const double radius = to_d(data[4]);
          const int32_t n = to_i(data[5]);

          autd3::FocusSTM stm;
          for (auto i = 0; i < n; i++) {
            const auto theta = 2.0 * autd3::pi * static_cast<double>(i) / static_cast<double>(n);
            autd3::Vector3 p = c + autd3::Vector3(radius * std::cos(theta), radius * std::sin(theta), 0);
            stm.add(p);
          }

          stm.set_frequency(freq);
          spdlog::info("lm: ({}, {}, {}), {}, {}, {}", c.x(), c.y(), c.z(), stm.frequency(), radius, n);

          _cnt->send(stm);
        } else if (cmd == "handrail_line") {
          const auto data = split(tokens[1], ',');
          autd3::Vector3 c = _cnt->geometry().center() + autd3::Vector3(0, 0, 200);
          const double freq = to_d(data[0]);
          const double len = to_d(data[1]);
          const double sample_len = to_d(data[2]);

          autd3::Vector3 start = c - autd3::Vector3(len / 2.0, 0.0, 0.0);

          autd3::FocusSTM stm;
          for (auto i = 0; i < static_cast<size_t>(len / sample_len) + 1; i++) {
            autd3::Vector3 p = start + autd3::Vector3(i * sample_len, 0, 0);
            stm.add(p);
          }

          stm.set_frequency(freq);
          spdlog::info("handrail_line: ({}, {}, {}), {}, {}, {}", c.x(), c.y(), c.z(), stm.frequency(), len, sample_len);

          _cnt->send(stm);
        } else if (cmd == "handrail_circle") {
          const auto data = split(tokens[1], ',');
          autd3::Vector3 c = _cnt->geometry().center() + autd3::Vector3(0, 0, 200);
          const double freq = to_d(data[0]);
          const double radius = to_d(data[1]);
          const double sample_len = to_d(data[2]);
          const auto n = static_cast<size_t>(autd3::pi * radius / sample_len);

          autd3::FocusSTM stm;
          for (auto i = 0; i < n; i++) {
            const auto theta = autd3::pi * static_cast<double>(i) / static_cast<double>(n);
            autd3::Vector3 p = c + autd3::Vector3(radius * std::cos(theta), radius * std::sin(theta), 0);
            stm.add(p);
          }

          stm.set_frequency(freq);
          spdlog::info("handrail_circle: ({}, {}, {}), {}, {}, {}", c.x(), c.y(), c.z(), stm.frequency(), len, sample_len);

          _cnt->send(stm);
        } else if (cmd == "pursuit") {
          const auto data = split(tokens[1], ',');
          autd3::Vector3 c = _cnt->geometry().center() + autd3::Vector3(0, 0, 200);
          const double freq = to_d(data[0]);
          const double len = to_d(data[1]);
          const double sample_len = to_d(data[2]);
          const auto n = static_cast<size_t>(2 * autd3::pi * len / sample_len);

          autd3::FocusSTM stm;
          for (auto i = 0; i < n; i++) {
            const auto theta = 2.0 * autd3::pi * static_cast<double>(i) / static_cast<double>(n);
            autd3::Vector3 p = c + autd3::Vector3(len * std::cos(theta), len * std::sin(theta), 0);
            stm.add(p);
          }

          stm.set_frequency(freq);
          spdlog::info("pursuit: ({}, {}, {}), {}, {}, {}", c.x(), c.y(), c.z(), stm.frequency(), len, sample_len);

          _cnt->send(stm);
        } else if (cmd == "sine") {
          const auto data = split(tokens[1], ',');
          const int32_t freq = to_i(data[0]);
          const double amp = to_d(data[1]);
          const double offset = to_d(data[2]);

          autd3::modulation::Sine m(freq, amp, offset);

          spdlog::info("sine: {}, {}, {}", freq, amp, offset);

          _cnt->send(m);
        } else if (cmd == "static") {
          const auto data = split(tokens[1], ',');
          const double amp = to_d(data[0]);

          autd3::modulation::Static m(amp);

          spdlog::info("static: {}", amp);

          _cnt->send(m);
        } else if (cmd == "silent") {
          const auto data = split(tokens[1], ',');
          const auto step = static_cast<uint16_t>(to_i(data[0]));
          const auto cycle = static_cast<uint16_t>(to_i(data[1]));

          autd3::SilencerConfig config(step, cycle);

          spdlog::info("silent: {}, {}", step, cycle);

          _cnt->send(config);
        } else if (cmd == "temp") {
          const auto data = split(tokens[1], ',');
          const double temp = to_d(data[0]);

          spdlog::info("temp: {}", temp);

          _cnt->geometry().set_sound_speed_from_temp(temp);
        } else if (cmd == "stop") {
          _cnt->send(autd3::Stop());
        }

        const auto response = fmt::format("{}/{}", cmd, result);
        send(_dst_socket, reinterpret_cast<const char*>(response.data()), static_cast<int>(response.size()), 0);
      }
    });
  }

  void close() {
    if (!_is_open) {
      spdlog::info("Already closed.");
      return;
    }

    _is_open = false;
    if (_th.joinable()) _th.join();

    if (_dst_socket != -1) {
      ::close(_dst_socket);
      _dst_socket = -1;
    }
    if (_socket != -1) {
      ::close(_socket);
      _socket = -1;
    }
  }

  [[nodiscard]] bool is_open() const noexcept { return _is_open; }

 private:
  bool _is_open{false};
  std::thread _th;
  uint16_t _port;
  int _socket{};
  int _dst_socket{};

  std::unique_ptr<autd3::Controller> _cnt{nullptr};
};
}  // namespace autd3demo

int main(void) {
  signal(SIGPIPE, SIG_IGN);

  autd3demo::App app;
  while (true) {
    if (!app.is_open()) app.connect();
    std::this_thread::sleep_for(std::chrono::milliseconds(500));
  }

  return 0;
}
