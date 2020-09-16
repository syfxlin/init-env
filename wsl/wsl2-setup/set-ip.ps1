if (!$(netsh.exe interface ip show address "vEthernet (WSL)" | Out-String -Stream | Select-String "192.168.50.1")) {
	Start-Process -FilePath netsh.exe -ArgumentList 'interface ip add address "vEthernet (WSL)" 192.168.50.1 255.255.255.0' -Verb RunAs;
}

wsl.exe -d Ubuntu2 -u root ip addr add 192.168.50.2/24 broadcast 192.168.50.255 dev eth0 label eth0:1;