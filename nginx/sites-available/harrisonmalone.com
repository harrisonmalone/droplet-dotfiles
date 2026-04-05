limit_req_zone $binary_remote_addr zone=mylimit:10m rate=1r/s;

server {
    listen 80;
    server_name harrisonmalone.com www.harrisonmalone.com;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    server_name harrisonmalone.com www.harrisonmalone.com;

    ssl_certificate /etc/letsencrypt/live/harrisonmalone.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/harrisonmalone.com/privkey.pem;
    ssl_trusted_certificate /etc/letsencrypt/live/harrisonmalone.com/chain.pem;

    # Security settings
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers 'TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384';

    # Enable session resumption to improve SSL/TLS performance
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    # Allow for larger request body to be passed
    client_max_body_size 20M;

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    limit_req zone=mylimit burst=20 nodelay;
}
