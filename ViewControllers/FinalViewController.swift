import UIKit

final class FinalViewController: UIViewController {

    private let items: [UserUsageHistory.BookItemResponse]
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let summaryStackView = UIStackView()
    private let totalRecordsLabel = UILabel()
    private let totalPriceLabel = UILabel()

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
        title = "Usage History"

        setupSummaryView()
        setupTableView()
        layoutViews()
        updateSummary()
    }

    private func setupSummaryView() {
        summaryStackView.translatesAutoresizingMaskIntoConstraints = false
        summaryStackView.axis = .vertical
        summaryStackView.spacing = 8
        summaryStackView.alignment = .leading

        totalRecordsLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        totalPriceLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)

        summaryStackView.addArrangedSubview(totalRecordsLabel)
        summaryStackView.addArrangedSubview(totalPriceLabel)
    }

    private func setupTableView() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 72
    }

    private func layoutViews() {
        view.addSubview(summaryStackView)
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            summaryStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            summaryStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            summaryStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            tableView.topAnchor.constraint(equalTo: summaryStackView.bottomAnchor, constant: 12),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func updateSummary() {
        let totalRecords = items.count
        let totalPrice = items.reduce(0.0) { $0 + $1.price }

        totalRecordsLabel.text = "Total Records: \(totalRecords)"
        totalPriceLabel.text = "Total Price: \(totalPrice)"
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell")
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: "HistoryCell")
        let item = items[indexPath.row]

        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.numberOfLines = 0

        let aText = "A: \(item.locationA.name) (\(item.locationA.latitude), \(item.locationA.longitude)) AQI: \(item.locationA.aqi)"
        let bText = "B: \(item.locationB.name) (\(item.locationB.latitude), \(item.locationB.longitude)) AQI: \(item.locationB.aqi)"
        cell.textLabel?.text = "\(aText)\n\(bText)"
        cell.detailTextLabel?.text = "Price: \(item.price)"

        return cell
    }
}

