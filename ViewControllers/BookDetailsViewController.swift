import UIKit

final class BookDetailsViewController: UIViewController {
    private let response: BooksInfoService.BookResponse
    var onBackToRoot: (() -> Void)?

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

        continueButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.setTitle("V", for: .normal)
        continueButton.setTitleColor(.black, for: .normal)
        continueButton.backgroundColor = .systemYellow
        continueButton.layer.cornerRadius = 10
        continueButton.addTarget(self, action: #selector(handleContinue), for: .touchUpInside)

        let sectionA = makeLocationSection(
            slotTitle: "A",
            locationName: response.locationA.name,
            airQuality: response.locationA.airQuality,
            nickname: response.locationA.name
        )
        let sectionB = makeLocationSection(
            slotTitle: "B",
            locationName: response.locationB.name,
            airQuality: response.locationB.airQuality,
            nickname: response.locationB.name
        )
        let contentStack = UIStackView(arrangedSubviews: [sectionA, sectionB])
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.alignment = .fill

        let priceTitleLabel = UILabel()
        priceTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        priceTitleLabel.text = "price"
        priceTitleLabel.textColor = .secondaryLabel
        priceTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)

        let priceValueLabel = UILabel()
        priceValueLabel.translatesAutoresizingMaskIntoConstraints = false
        priceValueLabel.text = "\(response.price)"
        priceValueLabel.textColor = .label
        priceValueLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)

        let priceRow = UIView()
        priceRow.translatesAutoresizingMaskIntoConstraints = false
        priceRow.addSubview(priceTitleLabel)
        priceRow.addSubview(priceValueLabel)

        NSLayoutConstraint.activate([
            priceTitleLabel.leadingAnchor.constraint(equalTo: priceRow.leadingAnchor),
            priceTitleLabel.topAnchor.constraint(equalTo: priceRow.topAnchor),
            priceTitleLabel.bottomAnchor.constraint(equalTo: priceRow.bottomAnchor),

            priceValueLabel.trailingAnchor.constraint(equalTo: priceRow.trailingAnchor),
            priceValueLabel.centerYAnchor.constraint(equalTo: priceTitleLabel.centerYAnchor)
        ])

        view.addSubview(contentStack)
        view.addSubview(priceRow)
        view.addSubview(continueButton)

        NSLayoutConstraint.activate([
            contentStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            contentStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            contentStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            priceRow.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            priceRow.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            priceRow.bottomAnchor.constraint(equalTo: continueButton.topAnchor, constant: -16),

            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            continueButton.heightAnchor.constraint(equalToConstant: 52),

            contentStack.bottomAnchor.constraint(lessThanOrEqualTo: priceRow.topAnchor, constant: -24)
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

    private func makeLocationSection(
        slotTitle: String,
        locationName: String,
        airQuality: Int,
        nickname: String
    ) -> UIView {
        let container = UIView()
        container.translatesAutoresizingMaskIntoConstraints = false

        let slotLabel = UILabel()
        slotLabel.translatesAutoresizingMaskIntoConstraints = false
        slotLabel.text = slotTitle
        slotLabel.textColor = .label
        slotLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)

        let nameLabel = UILabel()
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.text = locationName
        nameLabel.textColor = .label
        nameLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        nameLabel.numberOfLines = 0

        let aqiTitleLabel = UILabel()
        aqiTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        aqiTitleLabel.text = "aqi"
        aqiTitleLabel.textColor = .secondaryLabel
        aqiTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)

        let aqiValueLabel = UILabel()
        aqiValueLabel.translatesAutoresizingMaskIntoConstraints = false
        aqiValueLabel.text = "\(airQuality)"
        aqiValueLabel.textColor = .label
        aqiValueLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)

        let nicknameTitleLabel = UILabel()
        nicknameTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        nicknameTitleLabel.text = "nickname"
        nicknameTitleLabel.textColor = .secondaryLabel
        nicknameTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)

        let nicknameValueLabel = UILabel()
        nicknameValueLabel.translatesAutoresizingMaskIntoConstraints = false
        nicknameValueLabel.text = nickname
        nicknameValueLabel.textColor = .label
        nicknameValueLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)

        container.addSubview(slotLabel)
        container.addSubview(nameLabel)
        container.addSubview(aqiTitleLabel)
        container.addSubview(aqiValueLabel)
        container.addSubview(nicknameTitleLabel)
        container.addSubview(nicknameValueLabel)

        NSLayoutConstraint.activate([
            slotLabel.topAnchor.constraint(equalTo: container.topAnchor),
            slotLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),

            nameLabel.leadingAnchor.constraint(equalTo: slotLabel.trailingAnchor, constant: 12),
            nameLabel.centerYAnchor.constraint(equalTo: slotLabel.centerYAnchor),
            nameLabel.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor),

            aqiTitleLabel.topAnchor.constraint(equalTo: slotLabel.bottomAnchor, constant: 8),
            aqiTitleLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),

            aqiValueLabel.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 100),
            aqiValueLabel.centerYAnchor.constraint(equalTo: aqiTitleLabel.centerYAnchor),

            nicknameTitleLabel.topAnchor.constraint(equalTo: aqiTitleLabel.bottomAnchor, constant: 8),
            nicknameTitleLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            nicknameTitleLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor),

            nicknameValueLabel.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 100),
            nicknameValueLabel.centerYAnchor.constraint(equalTo: nicknameTitleLabel.centerYAnchor)
        ])

        return container
    }
}
