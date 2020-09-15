## GRPC proto buffer for Rust and Flutter
For rustlang, it will generated code when we run the cargo application

For Flutter, go to mobile_application_flutter, run
```
protoc --dart_out=grpc:lib/modals -Iprotos --proto_path=../ grpc_protos/advice_service.proto  
```