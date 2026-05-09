import UIKit
import WebKit

// ─────────────────────────────────────────
// MARK: - Cấu hình AI Tools (thêm vào đây)
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
class HomeViewController: UIViewController {

    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let urlField  = UITextField()
    private let goButton  = UIButton(type: .system)
    private var barView   = UIView()

   override func viewDidLoad() {
    super.viewDidLoad()
    title = "CustomBVK"
    view.backgroundColor = .systemBackground
    setupBackground()
    setupURLBar()
    setupTable()
}

    func setupURLBar() {
        barView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(barView)

        urlField.placeholder = "Dán link AI bất kỳ vào đây..."
        urlField.borderStyle = .roundedRect
        urlField.keyboardType = .URL
        urlField.autocapitalizationType = .none
        urlField.autocorrectionType = .no
        urlField.returnKeyType = .go
        urlField.clearButtonMode = .whileEditing
        urlField.delegate = self
        urlField.translatesAutoresizingMaskIntoConstraints = false

        var btnConfig = UIButton.Configuration.filled()
        btnConfig.title = "Mở"
        btnConfig.cornerStyle = .medium
        goButton.configuration = btnConfig
        goButton.addTarget(self, action: #selector(openURL), for: .touchUpInside)
        goButton.translatesAutoresizingMaskIntoConstraints = false

        barView.addSubview(urlField)
        barView.addSubview(goButton)

        NSLayoutConstraint.activate([
            barView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            barView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            barView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            barView.heightAnchor.constraint(equalToConstant: 44),

            urlField.leadingAnchor.constraint(equalTo: barView.leadingAnchor),
            urlField.centerYAnchor.constraint(equalTo: barView.centerYAnchor),
            urlField.trailingAnchor.constraint(equalTo: goButton.leadingAnchor, constant: -8),
            urlField.heightAnchor.constraint(equalToConstant: 40),

            goButton.trailingAnchor.constraint(equalTo: barView.trailingAnchor),
            goButton.centerYAnchor.constraint(equalTo: barView.centerYAnchor),
            goButton.widthAnchor.constraint(equalToConstant: 56),
            goButton.heightAnchor.constraint(equalToConstant: 36),
        ])
    }

    func setupTable() {
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate   = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: barView.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    @objc func openURL() {
        guard var raw = urlField.text?.trimmingCharacters(in: .whitespaces), !raw.isEmpty else { return }
        if !raw.hasPrefix("http") { raw = "https://" + raw }
        guard let url = URL(string: raw) else { return }
        urlField.resignFirstResponder()
        pushWeb(url: url, title: url.host ?? raw)
    }

  func pushWeb(url: URL, title: String) {
        let vc = WebViewController(url: url, pageTitle: title)
        navigationController?.pushViewController(vc, animated: true)
    }

    func setupBackground() {
        let imageURL = "https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=1080"

        let bgView = UIImageView(frame: view.bounds)
        bgView.contentMode = .scaleAspectFill
        bgView.clipsToBounds = true
        bgView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

        let overlay = UIView(frame: view.bounds)
        overlay.backgroundColor = UIColor.black.withAlphaComponent(0.45)
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        bgView.addSubview(overlay)

        view.insertSubview(bgView, at: 0)

        DispatchQueue.global().async {
            guard let url = URL(string: imageURL),
                  let data = try? Data(contentsOf: url),
                  let img  = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                bgView.image = img
            }
        }
    }
}

// MARK: TableView
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tv: UITableView, numberOfRowsInSection s: Int) -> Int { AITools.list.count }
    func tableView(_ tv: UITableView, titleForHeaderInSection s: Int) -> String? { "Chọn AI hoặc dán link bên trên ☝️" }

    func tableView(_ tv: UITableView, cellForRowAt ip: IndexPath) -> UITableViewCell {
        let cell = tv.dequeueReusableCell(withIdentifier: "cell", for: ip)
        let t = AITools.list[ip.row]
        var cfg = cell.defaultContentConfiguration()
        cfg.text = "\(t.emoji)  \(t.name)"
        cfg.secondaryText = t.url
        cfg.secondaryTextProperties.color = .systemGray
        cfg.secondaryTextProperties.font  = .systemFont(ofSize: 12)
        cell.contentConfiguration = cfg
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    func tableView(_ tv: UITableView, didSelectRowAt ip: IndexPath) {
        tv.deselectRow(at: ip, animated: true)
        let t = AITools.list[ip.row]
        pushWeb(url: URL(string: t.url)!, title: t.name)
    }
}

// MARK: TextField
extension HomeViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ tf: UITextField) -> Bool { openURL(); return true }
}

// ─────────────────────────────────────────
// MARK: - WebViewController
// ─────────────────────────────────────────
class WebViewController: UIViewController {

    private var webView: WKWebView!
    private let progressBar = UIProgressView(progressViewStyle: .bar)
    private var kvoToken: NSKeyValueObservation?
    private var retryCount = 0
    private let maxRetry   = 2
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
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.clockwise"),
            style: .plain, target: self, action: #selector(reload))
        setupWebView()
        setupProgressBar()
        loadPage()
    }

    func setupWebView() {
        let cfg = WKWebViewConfiguration()
        cfg.allowsInlineMediaPlayback = true
        cfg.mediaTypesRequiringUserActionForPlayback = []
        cfg.websiteDataStore = .default()

        // Tắt các preference không cần để nhẹ hơn
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        cfg.defaultWebpagePreferences = prefs

        webView = WKWebView(frame: view.bounds, configuration: cfg)
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.decelerationRate = .normal
        webView.scrollView.contentInsetAdjustmentBehavior = .automatic

        // User agent Safari thật — tránh bị chặn
        webView.customUserAgent =
            "Mozilla/5.0 (iPhone; CPU iPhone OS 16_6 like Mac OS X) " +
            "AppleWebKit/605.1.15 (KHTML, like Gecko) " +
            "Version/16.6 Mobile/15E148 Safari/604.1"

        view.addSubview(webView)
        view.bringSubviewToFront(progressBar)
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

        kvoToken = webView.observe(\.estimatedProgress, options: .new) { [weak self] wv, _ in
            DispatchQueue.main.async {
                let p = Float(wv.estimatedProgress)
                self?.progressBar.setProgress(p, animated: true)
                self?.progressBar.isHidden = p >= 1.0
            }
        }
    }

    func loadPage() {
        retryCount = 0
        var req = URLRequest(url: url,
                             cachePolicy: .returnCacheDataElseLoad,
                             timeoutInterval: 25)
        req.setValue(webView.customUserAgent, forHTTPHeaderField: "User-Agent")
        webView.load(req)
    }

    @objc func reload() {
        retryCount = 0
        webView.reload()
    }

    deinit { kvoToken?.invalidate() }
}

// MARK: WKNavigationDelegate
extension WebViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        retryCount = 0
        progressBar.isHidden = true
        progressBar.setProgress(0, animated: false)
        // Cập nhật title theo trang web thật
        if let t = webView.title, !t.isEmpty { self.title = t }
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        handleError(error)
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation nav: WKNavigation!, withError error: Error) {
        guard (error as NSError).code != NSURLErrorCancelled else { return }
        handleError(error)
    }

    func handleError(_ error: Error) {
        progressBar.isHidden = true
        // Tự retry 2 lần trước khi báo lỗi
        if retryCount < maxRetry {
            retryCount += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { self.webView.reload() }
            return
        }
        let alert = UIAlertController(
            title: "Không tải được 😕",
            message: "Kiểm tra mạng rồi thử lại.\n\(error.localizedDescription)",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Thử lại", style: .default) { _ in self.loadPage() })
        alert.addAction(UIAlertAction(title: "Huỷ", style: .cancel))
        present(alert, animated: true)
    }

    func webView(_ webView: WKWebView,
                 decidePolicyFor action: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // Chặn URL không hợp lệ
        guard let url = action.request.url,
              url.scheme == "https" || url.scheme == "http" || url.scheme == "about"
        else { decisionHandler(.cancel); return }
        decisionHandler(.allow)
    }
}

// MARK: WKUIDelegate
extension WebViewController: WKUIDelegate {
    // Hỗ trợ JS alert/confirm/prompt — không thì trang AI sẽ bị treo
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let a = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default) { _ in completionHandler() })
        present(a, animated: true)
    }

    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let a = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK",  style: .default) { _ in completionHandler(true) })
        a.addAction(UIAlertAction(title: "Huỷ", style: .cancel)  { _ in completionHandler(false) })
        present(a, animated: true)
    }

    func webView(_ webView: WKWebView,
                 createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction,
                 windowFeatures: WKWindowFeatures) -> WKWebView? {
        // Link mở tab mới → load trong webview hiện tại
        if let url = navigationAction.request.url {
            webView.load(URLRequest(url: url))
        }
        return nil
    }
}

// ─────────────────────────────────────────
// MARK: - AboutViewController
// ─────────────────────────────────────────
class AboutViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Tác giả"
        view.backgroundColor = .systemGroupedBackground
        buildUI()
    }

    func buildUI() {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scroll)
        NSLayoutConstraint.activate([
            scroll.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scroll.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scroll.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scroll.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        let root = UIStackView()
        root.axis = .vertical
        root.alignment = .center
        root.spacing = 20
        root.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(root)
        NSLayoutConstraint.activate([
            root.topAnchor.constraint(equalTo: scroll.topAnchor, constant: 40),
            root.leadingAnchor.constraint(equalTo: scroll.leadingAnchor, constant: 20),
            root.trailingAnchor.constraint(equalTo: scroll.trailingAnchor, constant: -20),
            root.bottomAnchor.constraint(equalTo: scroll.bottomAnchor, constant: -40),
            root.widthAnchor.constraint(equalTo: scroll.widthAnchor, constant: -40),
        ])

        // Avatar
        let avatarWrap = UIView()
        avatarWrap.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        avatarWrap.layer.cornerRadius = 52
        avatarWrap.widthAnchor.constraint(equalToConstant: 104).isActive = true
        avatarWrap.heightAnchor.constraint(equalToConstant: 104).isActive = true
        let icon = UIImageView(image: UIImage(systemName: "person.2.circle.fill"))
        icon.tintColor = .systemBlue
        icon.contentMode = .scaleAspectFit
        icon.translatesAutoresizingMaskIntoConstraints = false
        avatarWrap.addSubview(icon)
        NSLayoutConstraint.activate([
            icon.centerXAnchor.constraint(equalTo: avatarWrap.centerXAnchor),
            icon.centerYAnchor.constraint(equalTo: avatarWrap.centerYAnchor),
            icon.widthAnchor.constraint(equalToConstant: 72),
            icon.heightAnchor.constraint(equalToConstant: 72),
        ])

        let appName = label("CustomBVK", size: 28, weight: .bold)
        let version = label("Phiên bản 1.0 · iOS 15+", size: 13, color: .secondaryLabel)

        // Card nhà phát triển
        let devCard = card(width: view.frame.width - 40)
        let devStack = vstack(spacing: 14)
        devCard.addSubview(devStack)
        pin(devStack, to: devCard, inset: 18)
        devStack.addArrangedSubview(label("👨‍💻  Nhà phát triển", size: 12, weight: .semibold, color: .systemBlue))
        devStack.addArrangedSubview(nameRow("🎓", "Văn Khoa"))
        devStack.addArrangedSubview(divider())
        devStack.addArrangedSubview(nameRow("🎓", "Cao Long"))

        // Card liên hệ
        let contactCard = card(width: view.frame.width - 40)
        let contactStack = vstack(spacing: 12)
        contactCard.addSubview(contactStack)
        pin(contactStack, to: contactCard, inset: 18)
        contactStack.addArrangedSubview(label("📬  Liên hệ", size: 12, weight: .semibold, color: .systemBlue))

        let emailBtn = UIButton(type: .system)
        emailBtn.setTitle("✉️  tranvantrinhhd@gmail.com", for: .normal)
        emailBtn.titleLabel?.font = .systemFont(ofSize: 15)
        emailBtn.contentHorizontalAlignment = .left
        emailBtn.addTarget(self, action: #selector(mailTap), for: .touchUpInside)
        contactStack.addArrangedSubview(emailBtn)

        let copy = label("© 2025 Văn Khoa & Cao Long\nAll rights reserved.", size: 12,
                         color: .tertiaryLabel, align: .center)
        copy.numberOfLines = 0

        root.addArrangedSubview(avatarWrap)
        root.addArrangedSubview(appName)
        root.addArrangedSubview(version)
        root.setCustomSpacing(28, after: version)
        root.addArrangedSubview(devCard)
        root.addArrangedSubview(contactCard)
        root.setCustomSpacing(28, after: contactCard)
        root.addArrangedSubview(copy)
    }

    // MARK: Helpers
    func label(_ text: String, size: CGFloat, weight: UIFont.Weight = .regular,
                color: UIColor = .label, align: NSTextAlignment = .center) -> UILabel {
        let l = UILabel()
        l.text = text; l.font = .systemFont(ofSize: size, weight: weight)
        l.textColor = color; l.textAlignment = align
        return l
    }

    func nameRow(_ emoji: String, _ name: String) -> UIStackView {
        let s = UIStackView()
        s.axis = .horizontal; s.spacing = 10
        let e = UILabel(); e.text = emoji; e.font = .systemFont(ofSize: 20)
        let n = UILabel(); n.text = name
        n.font = .systemFont(ofSize: 16, weight: .medium); n.textColor = .label
        s.addArrangedSubview(e); s.addArrangedSubview(n)
        return s
    }

    func divider() -> UIView {
        let v = UIView(); v.backgroundColor = .separator
        v.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        return v
    }

    func card(width: CGFloat) -> UIView {
        let v = UIView()
        v.backgroundColor = .secondarySystemGroupedBackground
        v.layer.cornerRadius = 14
        v.layer.shadowColor  = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.05
        v.layer.shadowRadius  = 6
        v.layer.shadowOffset  = CGSize(width: 0, height: 2)
        v.translatesAutoresizingMaskIntoConstraints = false
        v.widthAnchor.constraint(equalToConstant: width).isActive = true
        return v
    }

    func vstack(spacing: CGFloat) -> UIStackView {
        let s = UIStackView(); s.axis = .vertical; s.spacing = spacing
        s.translatesAutoresizingMaskIntoConstraints = false
        return s
    }

    func pin(_ child: UIView, to parent: UIView, inset: CGFloat) {
        NSLayoutConstraint.activate([
            child.topAnchor.constraint(equalTo: parent.topAnchor, constant: inset),
            child.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: inset),
            child.trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: -inset),
            child.bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: -inset),
        ])
    }

    @objc func mailTap() {
        if let url = URL(string: "mailto:tranvantrinhhd@gmail.com") {
            UIApplication.shared.open(url)
        }
    }
}

// Alias
typealias ViewController = HomeViewController
