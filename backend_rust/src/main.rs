use tonic::{Request, Response, Status};
use tonic::transport::Server;
use serde::Deserialize;

pub mod advice_service {
    tonic::include_proto!("advice_service");
}
use advice_service::{Question, Answer };
use advice_service::advice_service_server::{AdviceService, AdviceServiceServer};

#[derive(Default)]
pub struct MyAdviceService {

}
#[tonic::async_trait]
impl AdviceService for MyAdviceService {
    async fn ask(&self, question: Request<Question>) -> Result<Response<Answer>, Status> {
        Ok(
            Response::new(Answer{
                content:format!("{}", question.get_ref().content)
            })
        )
    } 

}
#[derive(Deserialize, Debug)]
struct Body {
    data: String
}

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let client = reqwest::Client::new();
    let res = client.post("http://httpbin.org/post").body("exact body").send().await?;
  
    println!("Status: {}", res.status());
    
    let body = res.json::<Body>().await?;
    print!("Body {}", body.data);


    let address = "127.0.0.1:50051".parse().unwrap();
    let advice_service = MyAdviceService::default();
    Server::builder()
    .add_service(AdviceServiceServer::new(advice_service))
    .serve(address).await?;
    Ok(())
}
