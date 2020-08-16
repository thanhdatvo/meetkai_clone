fn main() -> Result<(), Box<dyn std::error::Error>> {
    tonic_build::compile_protos("../grpc_protos/advice_service.proto");
    Ok(())
}