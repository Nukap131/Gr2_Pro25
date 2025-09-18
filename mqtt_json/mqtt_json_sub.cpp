#include <iostream>
#include <string>
#include <mqtt/client.h>
#include <nlohmann/json.hpp>

using json = nlohmann::json;

// ANSI farver
#define RESET   "\033[0m"
#define DIM     "\033[2m"
#define RED     "\033[31m"
#define GREEN   "\033[32m"
#define YELLOW  "\033[33m"
#define BLUE    "\033[34m"
#define MAGENTA "\033[35m"
#define CYAN    "\033[36m"

// Meget simpel JSON-"syntax highlight": strings=GRØN, tal=BLÅ, true/false/null=MAGENTA, { } [ ] : , = "dim"
std::string colorize_json(const std::string& s) {
    std::string out; out.reserve(s.size()*11/10);
    bool in_string=false; bool escape=false;

    auto is_digit = [](char c){ return (c>='0' && c<='9') || c=='-' || c=='+' || c=='.' || c=='e' || c=='E'; };

    for (size_t i=0;i<s.size();++i) {
        char c = s[i];

        if (in_string) {
            if (escape) { out.push_back(c); escape=false; continue; }
            if (c=='\\') { out.push_back(c); escape=true; continue; }
            if (c=='"')  { out += RESET; out.push_back(c); in_string=false; continue; }
            out.push_back(c);
            continue;
        }

        // Uden for string
        if (c=='"') { out += GREEN; out.push_back(c); in_string=true; continue; }

        // tal
        if (is_digit(c)) {
            out += BLUE;
            while (i<s.size() && is_digit(s[i])) { out.push_back(s[i]); ++i; }
            --i;
            out += RESET;
            continue;
        }

        // true/false/null
        if (i+3 < s.size() && s.compare(i,4,"true")==0)  { out += MAGENTA; out += "true";  out += RESET;  i+=3; continue; }
        if (i+4 < s.size() && s.compare(i,5,"false")==0) { out += MAGENTA; out += "false"; out += RESET;  i+=4; continue; }
        if (i+3 < s.size() && s.compare(i,4,"null")==0)  { out += MAGENTA; out += "null";  out += RESET;  i+=3; continue; }

        // strukturtegn lidt dæmpet
        if (c=='{'||c=='}'||c=='['||c==']'||c==':'||c==',') {
            out += DIM; out.push_back(c); out += RESET; continue;
        }

        // whitespace / andet
        out.push_back(c);
    }
    if (in_string) out += RESET;
    return out;
}

class cb : public virtual mqtt::callback {
public:
    void message_arrived(mqtt::const_message_ptr msg) override {
        try {
            auto j = json::parse(msg->to_string());

            // 1) Pænt indrykket JSON (med farver)
            std::string pretty = j.dump(4);
            std::cout << CYAN << "Topic: " << RESET << msg->get_topic() << "\n";
            std::cout << colorize_json(pretty) << "\n";

            // 2) Kort farvet opsummering
            if (j.contains("timestamp")) std::cout << YELLOW << "Timestamp: " << RESET << j["timestamp"] << "\n";
            if (j.contains("seq"))       std::cout << YELLOW << "Seq: "       << RESET << j["seq"]       << "\n";

            if (j.contains("metrics")) {
                for (auto& m : j["metrics"]) {
                    std::string name = m.value("name","?");
                    std::string dtype = m.value("dataType","?");
                    double val = 0.0;
                    try { val = m.at("value").get<double>(); } catch (...) {}
                    // simple thresholds for demo
                    const char* valColor = (name=="temperature" && val>=30.0) ? RED : (name=="temperature" && val>=25.0) ? YELLOW : GREEN;

                    std::cout << GREEN << "Metric: " << RESET << name
                              << " = " << valColor << val << RESET
                              << " (" << MAGENTA << dtype << RESET << ")\n";
                }
            }
            std::cout << DIM << "---------------------------" << RESET << "\n";
        }
        catch (std::exception& e) {
            std::cerr << RED << "Parse error: " << e.what() << RESET << "\n";
        }
    }
};

int main() {
    const std::string broker   = "tcp://127.0.0.1:1883";
    const std::string clientId = "victor-json-sub";
    const std::string topic    = "spBv1.0/UCL-SEE-A/NDATA/TL/VentSensor";

    mqtt::client cli(broker, clientId);
    cb handler;
    cli.set_callback(handler);

    mqtt::connect_options connOpts;
    cli.connect(connOpts);
    cli.subscribe(topic);

    std::cout << "Listening on " << topic << " ...\n";
    while (true) {
        auto msg = cli.consume_message();
        if (!msg) break;
        handler.message_arrived(msg);
    }
    cli.disconnect();
    return 0;
}
