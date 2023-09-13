//
//  CollectionViewTableViewCell.swift
//  NetFlixClone
//
//  Created by window1 on 2023/01/03.
//

import UIKit


protocol CollectionViewTableViewCellDelegate: AnyObject {
    func collectionViewTableCellDidTapCell(_ cell: CollectionViewTableViewCell, viewModel: TitlePreviewViewModel)
}

class CollectionViewTableViewCell: UITableViewCell {
    
    static let identifier = "CollectionViewTableViewCell"
    
    weak var delegate: CollectionViewTableViewCellDelegate?
    
    private var titles: [Title] = [Title]()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 140, height: 200)
        layout.scrollDirection = .horizontal
        let collecitonView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collecitonView.register(TitleCollectionViewCell.self, forCellWithReuseIdentifier: TitleCollectionViewCell.identifier)
        return collecitonView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .systemPink
        contentView.addSubview(collectionView)

        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.frame = contentView.bounds
    }
    
    public func configure(with titles: [Title]) {
        self.titles = titles
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    private func downloadTitleAt(indexPath: IndexPath) {
        DataPersistanceManager.shared.downloadTitleWith(model: titles[indexPath.row]) { result in
            switch result {
            case .success():
                NotificationCenter.default.post(name: NSNotification.Name("downloaded"), object: nil)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

extension CollectionViewTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TitleCollectionViewCell.identifier, for: indexPath) as? TitleCollectionViewCell else { return UICollectionViewCell()
        }
        
        guard let model = titles[indexPath.row].poster_path else { return UICollectionViewCell() }
        cell.configure(with: model)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        
        let title = titles[indexPath.row]
        guard let titleName = title.original_title ?? title.original_name else {
            return
        }
        APICaller.shared.searchToYouTube(with: titleName + " trailer", completion: { [weak self] result in
            switch result {
            case .success(let videoElement):
                
                let title = self?.titles[indexPath.row]
                guard let titleOverView = title?.overview else {
                    return
                }
                guard let strongSelf = self else {
                    return
                }
                let viewModel = TitlePreviewViewModel(title: titleName, youtubeView: videoElement, titleOverview: titleOverView)
                self?.delegate?.collectionViewTableCellDidTapCell(strongSelf, viewModel: viewModel)
            case .failure(let error):
                print(error.localizedDescription)
            }
        })
    }

    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
         let config = UIContextMenuConfiguration(
            identifier: nil,
            previewProvider: nil) { [weak self] _ in
                let downloadAction = UIAction(title: "🗄️ 다운로드", subtitle: nil, image: nil, identifier: nil, discoverabilityTitle: nil,
                                              state: .off) { _ in
                    self?.downloadTitleAt(indexPath: indexPaths[0])
                }
                let wishItem = UIAction(title: "❤️ 나중에보기", subtitle: nil, image: nil, identifier: nil, discoverabilityTitle: nil,
                                        state: .off) { _ in
                    print("WishList Tapped")
                }
                return UIMenu(title: "", image: nil, identifier: nil, options: .displayInline, children: [downloadAction, wishItem])
            }
        return config
    }
    
    
}

