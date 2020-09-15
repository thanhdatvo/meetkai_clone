use serde::Deserialize;
use tonic::transport::Server;
use tonic::{Code, Request, Response, Status};

pub mod advice_service {
    tonic::include_proto!("advice_service");
}
use advice_service::advice_service_server::{AdviceService, AdviceServiceServer};
use advice_service::{Answer, Question, Rating};

#[derive(Default)]
pub struct MyAdviceService {}
#[tonic::async_trait]
impl AdviceService for MyAdviceService {
    async fn ask(&self, request: Request<Question>) -> Result<Response<Answer>, Status> {
        let question = request.into_inner();
        match get_data(question.user_id, &question.content).await {
            Ok(body) => Ok(Response::new(Answer { rates: body })),
            _ => Err(Status::new(Code::InvalidArgument, "name is invalid")),
        }
    }
}
#[derive(Deserialize, Debug)]
struct Data {
    title: String,
    id: i32,
    est: f32,
}

async fn get_data(
    user_id: i32,
    movie_title: &str,
) -> Result<Vec<Rating>, Box<dyn std::error::Error>> {
    let client = reqwest::Client::new();
    let url = format!(
        "http://127.0.0.1:5000/api/suggested_movies/{}/{}",
        user_id, movie_title
    );
    let res = client.get(&url).send().await?;

    println!("Status: {:#?}", res);

    let body = res.json::<Vec<Data>>().await?;
    let body = body
        .iter()
        .map(|data| Rating {
            title: data.title.to_string(),
            id: data.id,
            est: data.est,
        })
        .collect();
    print!("Body {:?}", body);
    Ok(body)
}
#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    let address = "127.0.0.1:50051".parse().unwrap();
    let advice_service = MyAdviceService::default();
    Server::builder()
        .add_service(AdviceServiceServer::new(advice_service))
        .serve(address)
        .await?;
    Ok(())
}
