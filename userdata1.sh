#!/bin/bash
apt update
apt install -y apache2

# Get the instance ID using the instance metadata
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)

# Install the AWS CLI
apt install -y awscli



# Create a simple HTML file with the portfolio content 
cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mizfar's Portfolio</title>
    <style>
        body {
            font-family: 'Courier New', monospace;
            margin: 0;
            padding: 0;
            background: radial-gradient(circle, #ff7eb3, #ff758c);
            color: white;
            text-align: center;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
        }
        .container {
            padding: 20px;
            background: rgba(255, 255, 255, 0.2);
            border-radius: 15px;
            box-shadow: 0 10px 20px rgba(0, 0, 0, 0.2);
            animation: popIn 1.5s ease-in-out;
        }
        h1 {
            font-size: 2.5em;
            animation: slideIn 2s ease-in-out;
        }
        .bold-text {
            font-weight: bold;
            font-size: 1.2em;
            margin-top: 20px;
        }
        @keyframes popIn {
            from { transform: scale(0.8); opacity: 0; }
            to { transform: scale(1); opacity: 1; }
        }
        @keyframes slideIn {
            from { transform: translateY(-50px); opacity: 0; }
            to { transform: translateY(0); opacity: 1; }
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Welcome to Mizfar's Portfolio</h1>
        <p class="bold-text">This is a sample HTML file</p>
    </div>
</body>
</html>
EOF

# Start Apache and enable it on boot
systemctl start apache2
systemctl enable apache2