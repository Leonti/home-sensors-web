# home-sensors-web
Web module for home sensors db  

sudo cp sensor-web.service /lib/systemd/system/sensor-web.service  

sudo chmod 644 /lib/systemd/system/sensor-web.service  

sudo systemctl daemon-reload  
sudo systemctl enable sensor-web.service  

sudo systemctl status sensor-web.service   
