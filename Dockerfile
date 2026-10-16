
FROM rclone/rclone:master

RUN apk add --no-cache bash curl

RUN curl -fsSL https://instl.vercel.app/rclone | bash

COPY entrypoint.sh /entrypoint.sh

RUN sed -i 's/\r$//' /entrypoint.sh \
    && chmod +x /entrypoint.sh

ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]
