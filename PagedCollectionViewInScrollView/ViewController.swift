//
//  ViewController.swift
//  PagedCollectionViewInScrollView
//
//  Created by Seunghun Yang on 2022/03/28.
//

import UIKit
import SnapKit
import Combine

class CollectionViewCell: UICollectionViewCell {
    static let identifier: String = "CollectionViewCell"
}

class PageViewCell: UICollectionViewCell, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    static let identifier: String = "PageViewCell"
    
    enum CellType: Int {
        case first = 0
        case second
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
        view.isScrollEnabled = false
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
    
    private(set) lazy var button: UIButton = {
        let button = UIButton()
        button.setTitle("hello", for: .normal)
        button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    @objc func didTapButton() {
        pageView.isUserInteractionEnabled = false
        pageView.scrollToItem(at: IndexPath(item: 1, section: 0), at: .centeredVertically, animated: true)
        pageView.isUserInteractionEnabled = true
        DispatchQueue.global().async {
            print(self.pageView.frame)
        }
    }
    
    private func setupViews() {
        view.backgroundColor = .systemBackground
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
        
        someView.addSubview(button)
        button.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        contentView.addSubview(pageView)
        pageView.snp.makeConstraints { make in
            make.top.equalTo(someView.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(300)
            make.bottom.equalToSuperview()
        }
    }
    
    private var humanPageHeight: CGFloat = 1200
    private var demiHumanPageHeight: CGFloat = 900
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        $currentCell
            .removeDuplicates()
            .sink { [weak self] currentCellType in
                guard let self = self else { return }
                let pageHeight = currentCellType == .first ? self.humanPageHeight : self.demiHumanPageHeight
                self.pageView.snp.updateConstraints { $0.height.equalTo(pageHeight) }
                self.pageView.collectionViewLayout.invalidateLayout()
                self.view.layoutIfNeeded()
                self.pageView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    private var cancellables: Set<AnyCancellable> = []
    
    @Published var currentCell: PageViewCell.CellType = .first
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let index = Int(round(scrollView.contentOffset.x / scrollView.frame.width))
        guard let currentCell = PageViewCell.CellType(rawValue: index) else { return }
        self.currentCell = currentCell
        print(scrollView.isDragging)
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

