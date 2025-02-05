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
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background: linear-gradient(135deg, #1e3c72, #2a5298);
            color: white;
            text-align: center;
        }
        .container {
            padding: 50px;
        }
        h1 {
            font-size: 2.5em;
            animation: fadeIn 2s ease-in-out;
        }
        .bold-text {
            font-weight: bold;
            font-size: 1.2em;
            margin-top: 20px;
        }
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(-20px); }
            to { opacity: 1; transform: translateY(0); }
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