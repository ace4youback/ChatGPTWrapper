import UIKit
import WebKit

// ─────────────────────────────────────────
// MARK: - Cấu hình AI Tools
// ─────────────────────────────────────────
struct AITools {
    static let list: [(name: String, url: String)] = [
        ("ChatGPT",    "https://chat.openai.com"),
        ("Claude",     "https://claude.ai"),
        ("Gemini",     "https://gemini.google.com"),
        ("Copilot",    "https://copilot.microsoft.com"),
        ("Grok",       "https://grok.com"),
        ("Perplexity", "https://perplexity.ai"),
        ("DeepSeek",   "https://chat.deepseek.com"),
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

    func setupBackground() {
        let imageURL = "https://i.postimg.cc/d3Lc8BXV/6bada5a7c42244918513dff82b6b958d-tplv-jj85edgx6n-image-origin.jpg"
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
            DispatchQueue.main.async { bgView.image = img }
        }
    }

    func setupURLBar() {
        barView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(barView)

        urlField.placeholder = "Dán link bất kỳ"
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
        tableView.backgroundColor = .clear
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
}

// MARK: TableView
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tv: UITableView, numberOfRowsInSection s: Int) -> Int { AITools.list.count }
    func tableView(_ tv: UITableView, titleForHeaderInSection s: Int) -> String? { "Chọn AI ☝️" }

    func tableView(_ tv: UITableView, cellForRowAt ip: IndexPath) -> UITableViewCell {
        let cell = tv.dequeueReusableCell(withIdentifier: "cell", for: ip)
        let t = AITools.list[ip.row]
        var cfg = cell.defaultContentConfiguration()
        cfg.text = t.name
        cfg.textProperties.font = .systemFont(ofSize: 16, weight: .medium)
        cfg.secondaryText = t.url
        cfg.secondaryTextProperties.color = .systemGray
        cfg.secondaryTextProperties.font  = .systemFont(ofSize: 12)
        cell.contentConfiguration = cfg
        cell.accessoryType = .disclosureIndicator
        cell.backgroundColor = UIColor.white.withAlphaComponent(0.15)
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
// MARK: - WebViewController (full màn hình)
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
        // Full screen — ẩn tab bar khi vào web
        hidesBottomBarWhenPushed = true
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

        // ✅ Lưu cookie & session — không bị logout
        cfg.websiteDataStore = WKWebsiteDataStore.default()

        // ✅ Shared cookie với Safari (lấy tài khoản Google đã đăng nhập)
        cfg.websiteDataStore.httpCookieStore.getAllCookies { cookies in
            for cookie in cookies {
                cfg.websiteDataStore.httpCookieStore.setCookie(cookie) { }
            }
        }

        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        cfg.defaultWebpagePreferences = prefs

        // Layout full màn hình — edge to edge
        webView = WKWebView(frame: .zero, configuration: cfg)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.decelerationRate = .normal
        webView.scrollView.contentInsetAdjustmentBehavior = .automatic

        // User agent Safari thật
        webView.customUserAgent =
            "Mozilla/5.0 (iPhone; CPU iPhone OS 16_6 like Mac OS X) " +
            "AppleWebKit/605.1.15 (KHTML, like Gecko) " +
            "Version/16.6 Mobile/15E148 Safari/604.1"

        view.addSubview(webView)

        // ✅ Full màn hình — edge to edge kể cả safe area
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
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
        var req = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 25)
        req.setValue(webView.customUserAgent, forHTTPHeaderField: "User-Agent")
        webView.load(req)
    }

    @objc func reload() { retryCount = 0; webView.reload() }
    deinit { kvoToken?.invalidate() }
}

// MARK: WKNavigationDelegate
extension WebViewController: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        retryCount = 0
        progressBar.isHidden = true
        progressBar.setProgress(0, animated: false)
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
        if retryCount < maxRetry {
            retryCount += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { self.webView.reload() }
            return
        }
        let alert = UIAlertController(title: "Không tải được",
                                      message: "Kiểm tra mạng rồi thử lại.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Thử lại", style: .default) { _ in self.loadPage() })
        alert.addAction(UIAlertAction(title: "Huỷ", style: .cancel))
        present(alert, animated: true)
    }

    func webView(_ webView: WKWebView, decidePolicyFor action: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = action.request.url,
              ["https","http","about"].contains(url.scheme ?? "")
        else { decisionHandler(.cancel); return }
        decisionHandler(.allow)
    }
}

// MARK: WKUIDelegate
extension WebViewController: WKUIDelegate {

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

    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration,
                 for navigationAction: WKNavigationAction,
                 windowFeatures: WKWindowFeatures) -> WKWebView? {
        if let url = navigationAction.request.url { webView.load(URLRequest(url: url)) }
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

        let appName = lbl("CustomBVK", size: 28, weight: .bold)
        let version = lbl("Phiên bản 1.0 · iOS 15+", size: 13, color: .secondaryLabel)

        let devCard = card()
        let devStack = vstack(16)
        devCard.addSubview(devStack)
        pin(devStack, to: devCard)
        devStack.addArrangedSubview(lbl("👨‍💻  Nhà phát triển", size: 12, weight: .semibold, color: .systemBlue))
        devStack.addArrangedSubview(nameRow("Văn Khoa"))
        devStack.addArrangedSubview(divider())
        devStack.addArrangedSubview(nameRow("Cao Long"))

        let contactCard = card()
        let contactStack = vstack(12)
        contactCard.addSubview(contactStack)
        pin(contactStack, to: contactCard)
        contactStack.addArrangedSubview(lbl("📬  Liên hệ", size: 12, weight: .semibold, color: .systemBlue))
        let emailBtn = UIButton(type: .system)
        emailBtn.setTitle("tranvantrinhhd@gmail.com", for: .normal)
        emailBtn.titleLabel?.font = .systemFont(ofSize: 15)
        emailBtn.contentHorizontalAlignment = .left
        emailBtn.addTarget(self, action: #selector(mailTap), for: .touchUpInside)
        contactStack.addArrangedSubview(emailBtn)

        let copy = lbl("© 2025 Văn Khoa & Cao Long\nAll rights reserved.", size: 12, color: .tertiaryLabel)
        copy.numberOfLines = 0
        copy.textAlignment = .center

        root.addArrangedSubview(avatarWrap)
        root.addArrangedSubview(appName)
        root.addArrangedSubview(version)
        root.setCustomSpacing(28, after: version)
        root.addArrangedSubview(devCard)
        root.addArrangedSubview(contactCard)
        root.setCustomSpacing(28, after: contactCard)
        root.addArrangedSubview(copy)
    }

    func lbl(_ text: String, size: CGFloat, weight: UIFont.Weight = .regular, color: UIColor = .label) -> UILabel {
        let l = UILabel(); l.text = text
        l.font = .systemFont(ofSize: size, weight: weight); l.textColor = color
        return l
    }

    func nameRow(_ name: String) -> UIStackView {
        let s = UIStackView(); s.axis = .horizontal; s.spacing = 10
        let n = UILabel(); n.text = name
        n.font = .systemFont(ofSize: 16, weight: .medium); n.textColor = .label
        s.addArrangedSubview(n)
        return s
    }

    func divider() -> UIView {
        let v = UIView(); v.backgroundColor = .separator
        v.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
        return v
    }

    func card() -> UIView {
        let v = UIView()
        v.backgroundColor = .secondarySystemGroupedBackground
        v.layer.cornerRadius = 14
        v.layer.shadowColor = UIColor.black.cgColor
        v.layer.shadowOpacity = 0.05
        v.layer.shadowRadius = 6
        v.layer.shadowOffset = CGSize(width: 0, height: 2)
        v.translatesAutoresizingMaskIntoConstraints = false
        v.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 40).isActive = true
        return v
    }

    func vstack(_ spacing: CGFloat) -> UIStackView {
        let s = UIStackView(); s.axis = .vertical; s.spacing = spacing
        s.translatesAutoresizingMaskIntoConstraints = false; return s
    }

    func pin(_ child: UIView, to parent: UIView) {
        NSLayoutConstraint.activate([
            child.topAnchor.constraint(equalTo: parent.topAnchor, constant: 18),
            child.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: 18),
            child.trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: -18),
            child.bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: -18),
        ])
    }

    @objc func mailTap() {
        if let url = URL(string: "mailto:tranvantrinhhd@gmail.com") {
            UIApplication.shared.open(url)
        }
    }
}

typealias ViewController = HomeViewController
