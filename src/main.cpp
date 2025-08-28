#include "logging.hpp"

int main() {
    init_logging();                 
    log_info("Program starter");
    log_warn("Lille advarsel");
    log_error("En fejlbesked");
    return 0;
}
