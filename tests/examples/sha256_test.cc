#include "examples/sha256.h"

#include <algorithm>
#include <vector>

#include "gtest/gtest.h"

namespace qcraft {
namespace crypto {

TEST(Sha256Test, TestSHA256SumForString) {
  const std::string string("SHA256 digest calculation test");
  const std::string expected_sha =
      "d9d746665dad66a84902ef1bb06a1600413718c971c82a2ddde2ea5731618ab5";
  EXPECT_EQ(SHA256SumForString(string), expected_sha);
}

}  // namespace crypto
}  // namespace qcraft
