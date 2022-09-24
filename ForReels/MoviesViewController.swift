//
//  MoviesViewController.swift
//  ForReels
//
//  Created by Matthew Nguyen on 9/15/22.
//  one viewcontroller for every screen

import UIKit
import AlamofireImage

class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {



    @IBOutlet weak var tableView: UITableView!
    
    // properties -> available for lifetime of screen
    var movies = [[String:Any]]() // array of dictionary with string:any -- () shows that its being created
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        // ran on the first time a screen comes up
        
        // need these two in order to call protocol functions
        tableView.dataSource = self
        tableView.delegate = self
        
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { (data, response, error) in
             // This will run when the network request returns
             if let error = error {
                    print(error.localizedDescription)
             } else if let data = data {
                    let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                    
                    self.movies = dataDictionary["results"] as! [[String:Any]] // as! casts it to match data type for movies
                    
                    self.tableView.reloadData() // recalls protocol functions
                    // print(dataDictionary)
                    
                 
                    // TODO: Store the movies in a property to use elsewhere
                    // TODO: Reload your table view data

             }
        }
        task.resume()
    }

    // protocols for tableView to let us work with it
    
    // asks for # of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    // for this row, give me cell -> configures cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell") as! MovieCell // reuses cell. if cell is offscreen, recycle cell / put info in memory
        
        let movie = movies[indexPath.row]
        let title = movie["title"] as! String // cast into string
        let synopsis = movie["overview"] as! String
        let rating = movie["vote_average"] as! Double
        
        cell.titleLabel!.text = title
        cell.synopsisLabel!.text = synopsis
        cell.ratingLabel!.text = String(rating) + "/10"
        
        let baseUrl = "https://image.tmdb.org/t/p/w185"
        let posterPath = movie["poster_path"] as! String
        let posterUrl = URL(string: baseUrl + posterPath)
        
        cell.posterView.af.setImage(withURL: posterUrl!)
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // sender -> cell that is tapped on
        
        // prepare for next screen
        // Get new VC using segue.destination
        // Pass selected object to the new view controller
        
        // Find selected movie
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPath(for: cell)!
        let movie = movies[indexPath.row]
        
        
        // Pass selected movie to details view controller
        let detailsViewController = segue.destination as! MovieDetailsViewController
        detailsViewController.movie = movie
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        
    }
}

