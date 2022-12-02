#ifndef EXPERIMENTAL_CC_SHARED_EXPERIMENT_BASE_SHA256_H_
#define EXPERIMENTAL_CC_SHARED_EXPERIMENT_BASE_SHA256_H_

#include <string>
#include <string_view>

#include "absl/status/statusor.h"
#include "absl/types/span.h"

namespace qcraft {
namespace crypto {

/**
 * @brief Compute SHA256 sum of file
 *
 * @param path Path to the file
 */
absl::StatusOr<std::string> Sha256SumForFile(std::string_view path);

/**
 * @brief Compute SHA256 sum for string
 *
 */
std::string SHA256SumForString(std::string_view str);
std::string SHA256SumForStrings(absl::Span<const std::string> strs);

}  // namespace crypto
}  // namespace qcraft

#endif  // EXPERIMENTAL_CC_SHARED_EXPERIMENT_BASE_SHA256_H_
