#!/bin/vbash

if ! dpkg -s wireguard >/dev/null 2>&1; then
    echo "WireGuard is not installed."
else
    echo "WireGuard is installed."
fi

echo "Test print!"
read -p "Test: " test
echo "You said: $test"

