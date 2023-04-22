// File: util.hpp
// Project: server
// Created Date: 22/04/2023
// Author: Shun Suzuki
// -----
// Last Modified: 22/04/2023
// Modified By: Shun Suzuki (suzuki@hapis.k.u-tokyo.ac.jp)
// -----
// Copyright (c) 2023 Shun Suzuki. All rights reserved.
//

#include <string>
#include <vector>

#include "autd3.hpp"

namespace autd3demo {

[[nodiscard]] inline std::vector<std::string> split(const std::string& s, const char deliminator) {
  std::vector<std::string> tokens;
  std::string token;
  for (const auto& ch : s) {
    if (ch == deliminator) {
      if (!token.empty()) tokens.emplace_back(token);
      token.clear();
    } else {
      token += ch;
    }
  }
  if (!token.empty()) tokens.emplace_back(token);
  return tokens;
}

[[nodiscard]] inline double to_d(const std::string& str) { return std::stod(str); }
[[nodiscard]] inline double to_a(const std::string& str) { return std::stod(str) / 180.0 * autd3::pi; }
[[nodiscard]] inline int32_t to_i(const std::string& str) { return static_cast<int32_t>(std::stoi(str)); }

}  // namespace autd3demo
