import UIKit
import WebKit
import MessageUI

// ─────────────────────────────────────────
// MARK: - Cấu hình AI Tools
// ─────────────────────────────────────────
struct AITools {
    static let list: [(name: String, url: String, emoji: String)] = [
        ("ChatGPT",    "https://chat.openai.com",       "🤖"),
        ("Claude",     "https://claude.ai",              "🧠"),
        ("Gemini",     "https://gemini.google.com",      "✨"),
        ("Copilot",    "https://copilot.microsoft.com",  "💡"),
        ("Grok",       "https://grok.com",               "⚡"),
        ("Perplexity", "https://perplexity.ai",          "🔍"),
        ("DeepSeek",   "https://chat.deepseek.com",      "🌊"),
    ]
}

// ─────────────────────────────────────────
// MARK: - HomeViewController
// ─────────────────────────────────────────
class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let urlField  = UITextField()
    private let goButton  = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "AI Browser"
        view.backgroundColor = .systemBackground
        setupURLBar()
        setupTable()
    }

    func setupURLBar() {
        let bar = UIView()
        bar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bar)

        urlField.placeholder = "Dán link AI bất kỳ vào đây..."
        urlField.borderStyle = .roundedRect
        urlField.keyboardType = .URL
        urlField.autocapitalizationType = .none
        urlField.autocorrectionType = .no
        urlField.returnKeyType = .go
        urlField.delegate = self
        urlField.translatesAutoresizingMaskIntoConstraints = false

        goButton.setTitle("Mở", for: .normal)
        goButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        goButton.addTarget(self, action: #selector(openURL), for: .touchUpInside)
        goButton.translatesAutoresizingMaskIntoConstraints = false

        bar.addSubview(urlField)
        bar.addSubview(goButton)

        NSLayoutConstraint.activate([
            bar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 12),
            bar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            bar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            bar.heightAnchor.constraint(equalToConstant: 44),

            urlField.leadingAnchor.constraint(equalTo: bar.leadingAnchor),
            urlField.centerYAnchor.constraint(equalTo: bar.centerYAnchor),
            urlField.trailingAnchor.constraint(equalTo: goButton.leadingAnchor, constant: -8),
            urlField.heightAnchor.constraint(equalToConstant: 40),

            goButton.trailingAnchor.constraint(equalTo: bar.trailingAnchor),
            goButton.centerYAnchor.constraint(equalTo: bar.centerYAnchor),
            goButton.widthAnchor.constraint(equalToConstant: 50),
        ])
    }

    func setupTable() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate   = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)

        let bar = view.subviews.first!
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: bar.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    @objc func openURL() {
        var raw = urlField.text?.trimmingCharacters(in: .whitespaces) ?? ""
        if raw.isEmpty { return }
        if !raw.hasPrefix("http") { raw = "https://" + raw }
        guard let url = URL(string: raw) else { return }
        urlField.resignFirstResponder()
        push(url: url, title: raw)
    }

    func push(url: URL, title: String) {
        navigationController?.pushViewController(
            WebViewController(url: url, pageTitle: title), animated: true)
    }

    // MARK: TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { AITools.list.count }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? { "Chọn AI hoặc dán link bên trên" }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let tool = AITools.list[indexPath.row]
        var cfg = cell.defaultContentConfiguration()
        cfg.text = "\(tool.emoji)  \(tool.name)"
        cfg.secondaryText = tool.url
        cfg.secondaryTextProperties.color = .systemGray
        cfg.secondaryTextProperties.font  = .systemFont(ofSize: 12)
        cell.contentConfiguration = cfg
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let tool = AITools.list[indexPath.row]
        push(url: URL(string: tool.url)!, title: tool.name)
    }
}

extension HomeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        openURL(); return true
    }
}

// ─────────────────────────────────────────
// MARK: - WebViewController
// ─────────────────────────────────────────
class WebViewController: UIViewController, WKNavigationDelegate, WKUIDelegate {

    private var webView: WKWebView!
    private let progressBar = UIProgressView(progressViewStyle: .bar)
    private var observation: NSKeyValueObservation?
    private let url: URL
    private let pageTitle: String

    init(url: URL, pageTitle: String) {
        self.url = url; self.pageTitle = pageTitle
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = pageTitle
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .refresh, target: self, action: #selector(reload))
        setupWebView()
        setupProgressBar()
        warmUpAndLoad()
    }

    func setupWebView() {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.websiteDataStore = .default()

        webView = WKWebView(frame: view.bounds, configuration: config)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.decelerationRate = .normal
        webView.customUserAgent =
            "Mozilla/5.0 (iPhone; CPU iPhone OS 16_6 like Mac OS X) " +
            "AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.6 Mobile/15E148 Safari/604.1"
        view.addSubview(webView)
    }

    func setupProgressBar() {
        progressBar.progressTintColor = .systemBlue
        progressBar.trackTintColor = .clear
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressBar)
        NSLayoutConstraint.activate([
            progressBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressBar.heightAnchor.constraint(equalToConstant: 3),
        ])
        observation = webView.observe(\.estimatedProgress, options: .new) { [weak self] wv, _ in
            let p = Float(wv.estimatedProgress)
            self?.progressBar.setProgress(p, animated: true)
            self?.progressBar.isHidden = p >= 1.0
        }
    }

    func warmUpAndLoad() {
        URLSession.shared.dataTask(
            with: URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 5)
        ) { _,_,_ in DispatchQueue.main.async { self.loadPage() } }.resume()
    }

    func loadPage() {
        var req = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 20)
        req.setValue(webView.customUserAgent, forHTTPHeaderField: "User-Agent")
        webView.load(req)
    }

    @objc func reload() { webView.reload() }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        progressBar.isHidden = true
        progressBar.setProgress(0, animated: false)
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) { showError() }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation nav: WKNavigation!, withError error: Error) {
        if (error as NSError).code != NSURLErrorCancelled { showError() }
    }

    func webView(_ webView: WKWebView, decidePolicyFor action: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in completionHandler() })
        present(alert, animated: true)
    }

    func showError() {
        let alert = UIAlertController(title: "Không tải được", message: "Kiểm tra mạng rồi thử lại.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Thử lại", style: .default) { _ in self.loadPage() })
        alert.addAction(UIAlertAction(title: "Huỷ", style: .cancel))
        present(alert, animated: true)
    }

    deinit { observation?.invalidate() }
}

// ─────────────────────────────────────────
// MARK: - AboutViewController (Tab Tác giả)
// ─────────────────────────────────────────
class AboutViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Tác giả"
        view.backgroundColor = .systemGroupedBackground
        setupUI()
    }

    func setupUI() {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)

        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(stack)

        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            stack.topAnchor.constraint(equalTo: scroll.topAnchor, constant: 40),
            stack.leadingAnchor.constraint(equalTo: scroll.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: scroll.trailingAnchor, constant: -24),
            stack.bottomAnchor.constraint(equalTo: scroll.bottomAnchor, constant: -40),
            stack.widthAnchor.constraint(equalTo: scroll.widthAnchor, constant: -48),
        ])

        // Avatar icon
        let avatarBg = UIView()
        avatarBg.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.12)
        avatarBg.layer.cornerRadius = 50
        avatarBg.translatesAutoresizingMaskIntoConstraints = false
        avatarBg.widthAnchor.constraint(equalToConstant: 100).isActive = true
        avatarBg.heightAnchor.constraint(equalToConstant: 100).isActive = true

        let avatarIcon = UIImageView(image: UIImage(systemName: "person.2.circle.fill"))
        avatarIcon.tintColor = .systemBlue
        avatarIcon.contentMode = .scaleAspectFit
        avatarIcon.translatesAutoresizingMaskIntoConstraints = false
        avatarBg.addSubview(avatarIcon)
        NSLayoutConstraint.activate([
            avatarIcon.centerXAnchor.constraint(equalTo: avatarBg.centerXAnchor),
            avatarIcon.centerYAnchor.constraint(equalTo: avatarBg.centerYAnchor),
            avatarIcon.widthAnchor.constraint(equalToConstant: 70),
            avatarIcon.heightAnchor.constraint(equalToConstant: 70),
        ])

        // App name
        let appLabel = UILabel()
        appLabel.text = "AI Browser"
        appLabel.font = .systemFont(ofSize: 26, weight: .bold)
        appLabel.textColor = .label
        appLabel.textAlignment = .center

        let versionLabel = UILabel()
        versionLabel.text = "Phiên bản 1.0 • iOS 15+"
        versionLabel.font = .systemFont(ofSize: 13)
        versionLabel.textColor = .secondaryLabel
        versionLabel.textAlignment = .center

        // Card tác giả
        let card = makeCard()
        let cardStack = UIStackView()
        cardStack.axis = .vertical
        cardStack.spacing = 16
        cardStack.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(cardStack)
        NSLayoutConstraint.activate([
            cardStack.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            cardStack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            cardStack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            cardStack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20),
        ])

        let devTitle = UILabel()
        devTitle.text = "👨‍💻  Nhà phát triển"
        devTitle.font = .systemFont(ofSize: 13, weight: .semibold)
        devTitle.textColor = .systemBlue

        cardStack.addArrangedSubview(devTitle)
        cardStack.addArrangedSubview(makeNameRow(emoji: "🎓", name: "Văn Khoa"))
        cardStack.addArrangedSubview(makeDivider())
        cardStack.addArrangedSubview(makeNameRow(emoji: "🎓", name: "Cao Long"))

        // Card liên hệ
        let contactCard = makeCard()
        let contactStack = UIStackView()
        contactStack.axis = .vertical
        contactStack.spacing = 12
        contactStack.translatesAutoresizingMaskIntoConstraints = false
        contactCard.addSubview(contactStack)
        NSLayoutConstraint.activate([
            contactStack.topAnchor.constraint(equalTo: contactCard.topAnchor, constant: 20),
            contactStack.leadingAnchor.constraint(equalTo: contactCard.leadingAnchor, constant: 20),
            contactStack.trailingAnchor.constraint(equalTo: contactCard.trailingAnchor, constant: -20),
            contactStack.bottomAnchor.constraint(equalTo: contactCard.bottomAnchor, constant: -20),
        ])

        let contactTitle = UILabel()
        contactTitle.text = "📬  Liên hệ"
        contactTitle.font = .systemFont(ofSize: 13, weight: .semibold)
        contactTitle.textColor = .systemBlue

        let emailBtn = UIButton(type: .system)
        emailBtn.setTitle("tranvantrinhhd@gmail.com", for: .normal)
        emailBtn.titleLabel?.font = .systemFont(ofSize: 15)
        emailBtn.contentHorizontalAlignment = .left
        emailBtn.addTarget(self, action: #selector(sendEmail), for: .touchUpInside)

        contactStack.addArrangedSubview(contactTitle)
        contactStack.addArrangedSubview(emailBtn)

        // Copyright
        let copy = UILabel()
        copy.text = "© 2025 Văn Khoa & Cao Long\nAll rights reserved."
        copy.font = .systemFont(ofSize: 12)
        copy.textColor = .tertiaryLabel
        copy.textAlignment = .center
        copy.numberOfLines = 0

        stack.addArrangedSubview(avatarBg)
        stack.addArrangedSubview(appLabel)
        stack.addArrangedSubview(versionLabel)
        stack.setCustomSpacing(32, after: versionLabel)
        stack.addArrangedSubview(card)
        stack.addArrangedSubview(contactCard)
        stack.setCustomSpacing(32, after: contactCard)
        stack.addArrangedSubview(copy)
    }

    func makeCard() -> UIView {
        let v = UIView()
        v.backgroundColor = .secondarySystemGroupedBackground
        v.layer.cornerRadius = 14
        v.translatesAutoresizingMaskIntoConstraints = false
        v.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -48).isActive = true
        return v
    }

    func makeNameRow(emoji: String, name: String) -> UIStackView {
        let row = UIStackView()
        row.axis = .horizontal
        row.spacing = 10

        let emojiL = UILabel()
        emojiL.text = emoji
        emojiL.font = .systemFont(ofSize: 20)

        let nameL = UILabel()
        nameL.text = name
        nameL.font = .systemFont(ofSize: 16, weight: .medium)
        nameL.textColor = .label

        row.addArrangedSubview(emojiL)
        row.addArrangedSubview(nameL)
        return row
    }

    func makeDivider() -> UIView {
        let v = UIView()
        v.backgroundColor = .separator
        v.translatesAutoresizingMaskIntoConstraints = false
        v.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        return v
    }

    @objc func sendEmail() {
        let email = "tranvantrinhhd@gmail.com"
        if let url = URL(string: "mailto:\(email)") {
            UIApplication.shared.open(url)
        }
    }
}

// Alias cũ vẫn hoạt động
typealias ViewController = HomeViewController
