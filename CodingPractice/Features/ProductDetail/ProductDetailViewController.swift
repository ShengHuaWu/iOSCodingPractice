import UIKit

final class ProductDetailViewController: UIViewController {
    private lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 36)
        label.textColor = .darkText
        label.numberOfLines = 0
        label.setContentHuggingPriority(.defaultHigh, for: .vertical)
        
        return label
    }()
    
    private lazy var favoriteButton: UIButton = {
        let button = UIButton(type: .roundedRect)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(.darkText, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        button.setContentHuggingPriority(.defaultHigh, for: .vertical)
        button.addTarget(self, action: #selector(toggleIsFavorited), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var descriptionLabal: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 24)
        label.textColor = .gray
        label.numberOfLines = 0
        
        return label
    }()
    
    private let viewModel: ProductDetailViewModel
    
    init(viewModel: ProductDetailViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Product Details"
        self.view.backgroundColor = .white
        
        self.addSubviews()
        self.configureLayoutConstraints()
        
        self.viewModel.onProductDetailChange { [weak self] state in
            guard let strongSelf = self else {
                return
            }
            
            switch state {
            case let .present(displayInfo):
                strongSelf.titleLabel.text = displayInfo.title
                strongSelf.descriptionLabal.text = displayInfo.description
                if displayInfo.isFavorited {
                    strongSelf.favoriteButton.setTitle("Unfavorite", for: .normal)
                } else {
                    strongSelf.favoriteButton.setTitle("Favorite", for: .normal)
                }
                
                strongSelf.view.layoutIfNeeded()
                
            case .error:
                // TODO: Present an alert?
                break
            }
        }
        
        self.viewModel.getProductDetail()
    }
    
    @objc func toggleIsFavorited() {
        self.viewModel.toggleIsFavorited()
    }
}

// MARK: - Private

private extension ProductDetailViewController {
    func addSubviews() {
        self.view.addSubview(self.titleLabel)
        self.view.addSubview(self.descriptionLabal)
        self.view.addSubview(self.favoriteButton)
    }
    
    func configureLayoutConstraints() {
        let layoutGuide = self.view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            self.titleLabel.topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: 18),
            self.titleLabel.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: 18),
            self.titleLabel.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: -18),
            self.favoriteButton.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 18),
            self.favoriteButton.leadingAnchor.constraint(equalTo: self.titleLabel.leadingAnchor),
            self.favoriteButton.trailingAnchor.constraint(equalTo: self.titleLabel.trailingAnchor),
            self.descriptionLabal.topAnchor.constraint(equalTo: self.favoriteButton.bottomAnchor, constant: 18),
            self.descriptionLabal.leadingAnchor.constraint(equalTo: self.titleLabel.leadingAnchor),
            self.descriptionLabal.trailingAnchor.constraint(equalTo: self.titleLabel.trailingAnchor),
            self.descriptionLabal.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor, constant: -18)
        ])
    }
}
