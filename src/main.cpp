#include "logging.hpp"
int main(){
  init_logging();
  log_info("Hello from spdlog via PlatformIO!");
  return 0;
}
