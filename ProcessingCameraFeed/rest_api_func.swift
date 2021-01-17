import Foundation

//Message is a Codable class

enum APIError:Error{
    case responseProblem
    case decodingProblem
    case otherProblem
}

struct APIRequest {
    let resourceURL:URL
    
    
    
    init(endpoint: String){
        //find host/postman?
        let resourceString = "\(endpoint)"
        guard let resourceURL = URL(string: resourceString) else {fatalError()}
        self.resourceURL = resourceURL
    }
    
    func save(_ messageToSave:Message, completion: @escaping(Result<Message, APIError>) -> Void){
        do{
            var urlRequest = URLRequest(url: resourceURL)
            urlRequest.httpMethod = "POST"
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = try JSONEncoder().encode(messageToSave)
            
            let dataTask = URLSession.shared.dataTask(with: urlRequest){ data, response, _ in
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200, let jsonData = data else{
                    completion(.failure(.responseProblem))
                    return
                }
                do{
                    // change Message.self
                    let messageData = try JSONDecoder().decode(Message.self, from: jsonData)
                    completion(.success(messageData))
                }catch{
                    completion(.failure(.decodingProblem))
                }
            }
            dataTask.resume()
        }catch{
            completion(.failure(.encodingProblem))
        }
    }
}
