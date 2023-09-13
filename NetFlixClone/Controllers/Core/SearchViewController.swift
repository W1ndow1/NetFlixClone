//
//  SearchViewController.swift
//  NetFlixClone
//
//  Created by window1 on 2023/01/03.
//

import UIKit
import SwiftUI

class SearchViewController: UIViewController {
    
    private var titles: [Title] = [Title]()

    private let discoverTable: UITableView = {
        let table = UITableView()
        table.register(TitleTableViewCell.self, forCellReuseIdentifier: TitleTableViewCell.identifier)
        return table
    }()
    
    private let searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: SearchResultsViewController())
        controller.searchBar.placeholder = "검색어를 입력하세요"
        controller.searchBar.searchBarStyle = .minimal
        return controller
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "찾기"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.largeTitleDisplayMode = .always
        
        view.addSubview(discoverTable)
        discoverTable.delegate = self 
        discoverTable.dataSource = self
        
        navigationItem.searchController = searchController
        navigationController?.navigationBar.tintColor = .white
        fetchDiscoverMovies()
        
        searchController.searchResultsUpdater = self
        
    }
    
    private func fetchDiscoverMovies() {
        APICaller.shared.discoverMovies(completion: { [weak self] result in
            switch result {
            case .success(let titles):
                self?.titles = titles
                DispatchQueue.main.async {
                    self?.discoverTable.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        })
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        discoverTable.frame = view.bounds
    }
}

extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TitleTableViewCell.identifier, for: indexPath) as? TitleTableViewCell else { return UITableViewCell() }
        let title = titles[indexPath.row]
        let model = TitleViewModel(titleName: title.title ?? title.original_title ?? "정보없음", posterURL: title.poster_path ?? "")
        cell.configure(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 140
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           tableView.deselectRow(at: indexPath, animated: true)
           
           let title = titles[indexPath.row]
           
           guard let titleName = title.original_title ?? title.original_name else {
               return
           }
           
           APICaller.shared.searchToYouTube(with: titleName, completion: { [weak self] result in
               switch result {
               case .success(let videoElement):
                   DispatchQueue.main.async {
                       let viewController = TitlePreviewViewController()
                       viewController.configure(with: TitlePreviewViewModel(title: titleName, youtubeView: videoElement, titleOverview: title.overview ?? ""))
                       self?.navigationController?.pushViewController(viewController, animated: true)
                   }
               case.failure(let error):
                   print(error.localizedDescription)
               }
           })
       }
}

struct VCPreiview: PreviewProvider {
    static var previews: some View {
        SearchViewController().toPreview()
    }
}

    
extension SearchViewController: UISearchResultsUpdating, SearchResultsViewControllerDelegate {
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        guard let query = searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty,
              query.trimmingCharacters(in: .whitespaces).count >= 3,
              let resultsController = searchController.searchResultsController as? SearchResultsViewController else {
            return
        }
        resultsController.delegate = self
        
        APICaller.shared.search(with: query) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let titles):
                    resultsController.titles = titles
                    resultsController.searchResultCollectionView.reloadData()
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func searchResultsViewControllerDidTapItem(_ viewModel: TitlePreviewViewModel) {
        DispatchQueue.main.async { [weak self] in
            let viewController = TitlePreviewViewController()
            viewController.configure(with: viewModel)
            self?.navigationController?.pushViewController(viewController, animated: true)
        }
    }
}
