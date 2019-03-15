# Boot 完整配置

```yaml
web:
  serviceId: null
  serviceName: service
  port: 3005
consul:
  host: localhost
  port: 8500
  # 多网卡或者容器场景下需要手动指定服务IP，否则可能会自动选择内网IP
  discoveryHost: localhost
  health_check:
    timeout: 1s
    interval: 10s
  max_retry: 5
  retry_interval: 5000
  config:
    # 如果服务名字是 user-service 并且 env 是 production，
    # 则 consul kv 中 key 为 config__user-service__production
    key: config__{serviceName}__{env}
    retry: 5
gateway:
  routes:
    - id: user
      uri: lb://multicloud-user-service
    - id: pay
      uri: http://pay.example.com
logger:
  level: info
  transports:
    - transport: console
      colorize: true
      datePattern: YYYY-MM-DD h:mm:ss
      label: nestcloud
    - transport: file
      name: info
      filename: info.log
      datePattern: YYYY-MM-DD h:mm:ss
      label: nestcloud
      maxSize: 104857600
      json: false
      maxFiles: 10
    - transport: dailyRotateFile
      label: nestcloud
      filename: info.log
      datePattern: YYYY-MM-DD-HH
      zippedArchive: true
      maxSize: 20m
      maxFiles: 14d
```
