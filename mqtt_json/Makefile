CXX=g++
CXXFLAGS=-std=c++17
LIBS=-lpaho-mqttpp3 -lpaho-mqtt3as

all: mqtt_json_sub mqtt_json_pub

mqtt_json_sub: mqtt_json_sub.cpp
	$(CXX) $(CXXFLAGS) $< -o $@ $(LIBS)

mqtt_json_pub: mqtt_json_pub.cpp
	$(CXX) $(CXXFLAGS) $< -o $@ $(LIBS)

clean:
	rm -f mqtt_json_sub mqtt_json_pub
