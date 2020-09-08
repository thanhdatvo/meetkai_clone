## GRPC proto buffer for Rust and Flutter
### For Flutter, go to mobile_application_flutter, run
```
protoc --dart_out=grpc:lib/modals -Iprotos --proto_path=../ grpc_protos/advice_service.proto  
```