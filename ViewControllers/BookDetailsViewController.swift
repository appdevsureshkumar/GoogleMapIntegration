import UIKit

final class BookDetailsViewController: UIViewController {
    private let response: BooksInfoService.BookResponse
    var onBackToRoot: (() -> Void)?

    private let stackView = UIStackView()
    private let continueButton = UIButton(type: .system)

    init(response: BooksInfoService.BookResponse) {
        self.response = response
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Booking"

        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.alignment = .leading

        let aLabel = makeLabel(
            title: "A",
            details: "\(response.locationA.name)\nLat: \(response.locationA.latitude)\nLng: \(response.locationA.longitude)\nAQI: \(response.locationA.airQuality)"
        )
        let bLabel = makeLabel(
            title: "B",
            details: "\(response.locationB.name)\nLat: \(response.locationB.latitude)\nLng: \(response.locationB.longitude)\nAQI: \(response.locationB.airQuality)"
        )
        let priceLabel = makeLabel(title: "Price", details: "\(response.price)")

        stackView.addArrangedSubview(aLabel)
        stackView.addArrangedSubview(bLabel)
        stackView.addArrangedSubview(priceLabel)

        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.setTitle("Continue", for: .normal)
        continueButton.setTitleColor(.white, for: .normal)
        continueButton.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.9)
        continueButton.layer.cornerRadius = 10
        continueButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
        continueButton.addTarget(self, action: #selector(handleContinue), for: .touchUpInside)

        view.addSubview(stackView)
        view.addSubview(continueButton)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isMovingFromParent {
            onBackToRoot?()
        }
    }

    @objc private func handleContinue() {
        let historyItem = UserUsageHistory.BookItemResponse(
            locationA: UserUsageHistory.BookItem(
                latitude: response.locationA.latitude,
                longitude: response.locationA.longitude,
                aqi: response.locationA.airQuality,
                name: response.locationA.name
            ),
            locationB: UserUsageHistory.BookItem(
                latitude: response.locationB.latitude,
                longitude: response.locationB.longitude,
                aqi: response.locationB.airQuality,
                name: response.locationB.name
            ),
            price: response.price
        )
        let itemOne = UserUsageHistory.BookItemResponse(
            locationA: UserUsageHistory.BookItem(
                latitude: 36.564,
                longitude: 127.001,
                aqi: 30,
                name: "Default location name one"
            ),
            locationB: UserUsageHistory.BookItem(
                latitude: 36.567,
                longitude: 127.0,
                aqi: 40,
                name: "Default location name two"
            ),
            price: 10000
        )
        let viewController = FinalViewController(items: [historyItem, itemOne])
        navigationController?.pushViewController(viewController, animated: true)
    }

    private func makeLabel(title: String, details: String) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.text = "\(title):\n\(details)"
        return label
    }
}
