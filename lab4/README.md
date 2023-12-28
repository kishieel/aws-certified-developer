```shell
curl \
  -X POST \
  -T image.png \
  "$(t output -raw fn-image-upload-url)"/upload 
```
