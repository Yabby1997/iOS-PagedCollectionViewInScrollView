//
//  ViewController.swift
//  PagedCollectionViewInScrollView
//
//  Created by Seunghun Yang on 2022/03/28.
//

import UIKit
import SnapKit

class CollectionViewCell: UICollectionViewCell {
    static let identifier: String = "CollectionViewCell"
}

class PageViewCell: UICollectionViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    static let identifier: String = "PageViewCell"
    
    enum CellType {
        case first, second
    }
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 8
        layout.minimumInteritemSpacing = 8
        layout.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.showsVerticalScrollIndicator = false
        view.register(CollectionViewCell.self, forCellWithReuseIdentifier: CollectionViewCell.identifier)
        view.backgroundColor = .clear
        return view
    }()
    
    var numberOfCells: Int = 0
    
    var contentSize: CGSize {
        collectionView.contentSize
    }
    
    var cellType: CellType = .first
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }
    
    private func setupViews() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        contentView.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    override func prepareForReuse() {
        numberOfCells = 0
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        numberOfCells
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 32) / 3
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.identifier, for: indexPath)
        cell.backgroundColor = .systemRed
        return cell
    }
}

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let someView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        return view
    }()
    
    private let pageView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = .zero
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.isPagingEnabled = true
        view.showsHorizontalScrollIndicator = false
        view.register(PageViewCell.self, forCellWithReuseIdentifier: PageViewCell.identifier)
        view.backgroundColor = .yellow
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    private func setupViews() {
        pageView.delegate = self
        pageView.dataSource = self
        
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        contentView.addSubview(someView)
        someView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(500)
        }
        
        contentView.addSubview(pageView)
        pageView.snp.makeConstraints { make in
            make.top.equalTo(someView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(300)
            make.bottom.equalToSuperview()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        layoutPageView()
    }
    
    func layoutPageView() {
        guard let visiblePage = pageView.visibleCells.first as? PageViewCell else { return }
        let pageHeight = visiblePage.contentSize.height
        pageView.snp.updateConstraints { $0.height.equalTo(pageHeight) }
        pageView.layoutIfNeeded()
        pageView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        layoutPageView()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        pageView.frame.size
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PageViewCell.identifier, for: indexPath)
        guard let cell = cell as? PageViewCell else { return cell }
        cell.numberOfCells = indexPath.item == 0 ? 17 : 12
        cell.backgroundColor = indexPath.item == 0 ? .blue : .green
        cell.cellType = indexPath.item == 0 ? .first : .second
        return cell
    }
}

