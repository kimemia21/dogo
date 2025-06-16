import qrcode

# Define the URL or IP address with port
ip_address = "192.168.1.8:3000"
url = f"http://{ip_address}"

# Generate the QR code
qr = qrcode.make(url)

# Save it as an image file
qr.save("qr_192.168.1.8_3000.png")
