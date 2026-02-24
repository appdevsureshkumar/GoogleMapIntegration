import UIKit

final class FinalViewController: UIViewController {

    private let items: [UserUsageHistory.BookItemResponse]
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let summaryContainerView = UIView()
    private let headerSeparatorView = UIView()
    private let summaryStackView = UIStackView()
    private let totalCountTitleLabel = UILabel()
    private let totalCountValueLabel = UILabel()
    private let totalPriceTitleLabel = UILabel()
    private let totalPriceValueLabel = UILabel()

    init(items: [UserUsageHistory.BookItemResponse]) {
        self.items = items
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = nil

        setupSummaryView()
        setupTableView()
        layoutViews()
        updateSummary()
    }

    private func setupSummaryView() {
        summaryContainerView.translatesAutoresizingMaskIntoConstraints = false
        summaryContainerView.backgroundColor = .systemBackground

        summaryStackView.translatesAutoresizingMaskIntoConstraints = false
        summaryStackView.axis = .horizontal
        summaryStackView.spacing = 16
        summaryStackView.alignment = .center
        summaryStackView.distribution = .fillEqually

        totalCountTitleLabel.text = "Total Count"
        totalCountTitleLabel.textColor = .secondaryLabel
        totalCountTitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        totalCountTitleLabel.textAlignment = .center

        totalCountValueLabel.textColor = .label
        totalCountValueLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        totalCountValueLabel.textAlignment = .center

        totalPriceTitleLabel.text = "Total Price"
        totalPriceTitleLabel.textColor = .secondaryLabel
        totalPriceTitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .semibold)
        totalPriceTitleLabel.textAlignment = .center

        totalPriceValueLabel.textColor = .label
        totalPriceValueLabel.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        totalPriceValueLabel.textAlignment = .center

        let totalCountStack = UIStackView(arrangedSubviews: [totalCountTitleLabel, totalCountValueLabel])
        totalCountStack.axis = .vertical
        totalCountStack.spacing = 6
        totalCountStack.alignment = .center

        let totalPriceStack = UIStackView(arrangedSubviews: [totalPriceTitleLabel, totalPriceValueLabel])
        totalPriceStack.axis = .vertical
        totalPriceStack.spacing = 6
        totalPriceStack.alignment = .center

        summaryStackView.addArrangedSubview(totalCountStack)
        summaryStackView.addArrangedSubview(totalPriceStack)

        summaryContainerView.addSubview(summaryStackView)
        headerSeparatorView.translatesAutoresizingMaskIntoConstraints = false
        headerSeparatorView.backgroundColor = .systemGray4
        summaryContainerView.addSubview(headerSeparatorView)
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.separatorStyle = .singleLine
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 64
        tableView.register(HistoryCell.self, forCellReuseIdentifier: HistoryCell.reuseIdentifier)
    }

    private func layoutViews() {
        view.addSubview(summaryContainerView)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            summaryContainerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            summaryContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            summaryContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            summaryStackView.topAnchor.constraint(equalTo: summaryContainerView.topAnchor, constant: 16),
            summaryStackView.bottomAnchor.constraint(equalTo: summaryContainerView.bottomAnchor, constant: -16),
            summaryStackView.leadingAnchor.constraint(equalTo: summaryContainerView.leadingAnchor, constant: 16),
            summaryStackView.trailingAnchor.constraint(equalTo: summaryContainerView.trailingAnchor, constant: -16),

            headerSeparatorView.leadingAnchor.constraint(equalTo: summaryContainerView.leadingAnchor),
            headerSeparatorView.trailingAnchor.constraint(equalTo: summaryContainerView.trailingAnchor),
            headerSeparatorView.bottomAnchor.constraint(equalTo: summaryContainerView.bottomAnchor),
            headerSeparatorView.heightAnchor.constraint(equalToConstant: 1),

            tableView.topAnchor.constraint(equalTo: summaryContainerView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func updateSummary() {
        let totalRecords = items.count
        let totalPrice = items.reduce(0.0) { $0 + $1.price }

        totalCountValueLabel.text = "\(totalRecords)"
        totalPriceValueLabel.text = "\(totalPrice)"
    }
}

extension FinalViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: HistoryCell.reuseIdentifier,
            for: indexPath
        ) as? HistoryCell ?? HistoryCell(style: .default, reuseIdentifier: HistoryCell.reuseIdentifier)
        let item = items[indexPath.row]

        cell.configure(
            aName: item.locationA.name,
            bName: item.locationB.name
        )

        return cell
    }
}

private final class HistoryCell: UITableViewCell {
    static let reuseIdentifier = "HistoryCell"

    private let aLabel = UILabel()
    private let aValueLabel = UILabel()
    private let bLabel = UILabel()
    private let bValueLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

        aLabel.translatesAutoresizingMaskIntoConstraints = false
        aLabel.text = "A"
        aLabel.textColor = .label
        aLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)

        aValueLabel.translatesAutoresizingMaskIntoConstraints = false
        aValueLabel.textColor = .label
        aValueLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        aValueLabel.numberOfLines = 1

        bLabel.translatesAutoresizingMaskIntoConstraints = false
        bLabel.text = "B"
        bLabel.textColor = .label
        bLabel.font = UIFont.systemFont(ofSize: 16, weight: .bold)

        bValueLabel.translatesAutoresizingMaskIntoConstraints = false
        bValueLabel.textColor = .label
        bValueLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        bValueLabel.numberOfLines = 1

        contentView.addSubview(aLabel)
        contentView.addSubview(aValueLabel)
        contentView.addSubview(bLabel)
        contentView.addSubview(bValueLabel)

        NSLayoutConstraint.activate([
            aLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            aLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),

            aValueLabel.leadingAnchor.constraint(equalTo: aLabel.trailingAnchor, constant: 12),
            aValueLabel.centerYAnchor.constraint(equalTo: aLabel.centerYAnchor),
            aValueLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16),

            bLabel.topAnchor.constraint(equalTo: aLabel.bottomAnchor, constant: 12),
            bLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            bLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),

            bValueLabel.leadingAnchor.constraint(equalTo: bLabel.trailingAnchor, constant: 12),
            bValueLabel.centerYAnchor.constraint(equalTo: bLabel.centerYAnchor),
            bValueLabel.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -16)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(aName: String, bName: String) {
        aValueLabel.text = aName
        bValueLabel.text = bName
    }
}
