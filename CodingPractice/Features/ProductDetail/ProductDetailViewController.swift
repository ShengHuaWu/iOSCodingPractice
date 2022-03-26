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
    
    private lazy var contentView: UIStackView = {
        let view = UIStackView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.axis = .vertical
        view.spacing = 18
        
        return view
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
        
        self.viewModel.subscribe { [weak self] event in
            guard let strongSelf = self else {
                return
            }
            
            switch event {
            case let .present(displayInfo):
                strongSelf.titleLabel.text = displayInfo.title
                strongSelf.descriptionLabal.text = displayInfo.description
                if displayInfo.isFavorited {
                    strongSelf.favoriteButton.setTitle("Unfavorite", for: .normal)
                    strongSelf.favoriteButton.setTitleColor(.red, for: .normal)
                } else {
                    strongSelf.favoriteButton.setTitle("Favorite", for: .normal)
                    strongSelf.favoriteButton.setTitleColor(.darkText, for: .normal)
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
        self.contentView.addArrangedSubview(self.titleLabel)
        self.contentView.addArrangedSubview(self.favoriteButton)
        self.contentView.addArrangedSubview(self.descriptionLabal)
        
        self.view.addSubview(self.contentView)
    }
    
    func configureLayoutConstraints() {
        let layoutGuide = self.view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            self.contentView.topAnchor.constraint(equalTo: layoutGuide.topAnchor, constant: 18),
            self.contentView.leadingAnchor.constraint(equalTo: layoutGuide.leadingAnchor, constant: 18),
            self.contentView.trailingAnchor.constraint(equalTo: layoutGuide.trailingAnchor, constant: -18),
            self.contentView.bottomAnchor.constraint(equalTo: layoutGuide.bottomAnchor, constant: -18)
        ])
    }
}
