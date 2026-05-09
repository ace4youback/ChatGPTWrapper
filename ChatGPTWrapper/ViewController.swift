import UIKit
import WebKit
import Network
import PhotosUI

// ─────────────────────────────────────────
// MARK: - Design Tokens
// ─────────────────────────────────────────
extension UIColor {
    static let accentBlue   = UIColor(red: 0.47, green: 0.71, blue: 1.00, alpha: 1)
    static let cardBg       = UIColor.white.withAlphaComponent(0.07)
    static let cardBorder   = UIColor.white.withAlphaComponent(0.10)
    static let labelPrimary = UIColor.white
    static let labelSub     = UIColor.white.withAlphaComponent(0.35)
}

// ─────────────────────────────────────────
// MARK: - AI Tools
// ─────────────────────────────────────────
struct AITool {
    let name: String
    let url: String
    let icon: String
    let iconColor: UIColor
    let iconBg: UIColor
    let badge: String?
}

struct AITools {
    static let list: [AITool] = [
        AITool(name: "ChatGPT",    url: "https://chat.openai.com",       icon: "message.fill",       iconColor: UIColor(red:0.06,green:0.64,blue:0.50,alpha:1), iconBg: UIColor(red:0.06,green:0.64,blue:0.50,alpha:0.18), badge: nil),
        AITool(name: "Claude",     url: "https://claude.ai",             icon: "sparkles",           iconColor: UIColor(red:0.80,green:0.55,blue:0.35,alpha:1), iconBg: UIColor(red:0.80,green:0.55,blue:0.35,alpha:0.18), badge: "HOT"),
        AITool(name: "Gemini",     url: "https://gemini.google.com",     icon: "diamond.fill",       iconColor: UIColor(red:0.26,green:0.52,blue:0.96,alpha:1), iconBg: UIColor(red:0.26,green:0.52,blue:0.96,alpha:0.18), badge: nil),
        AITool(name: "Copilot",    url: "https://copilot.microsoft.com", icon: "cpu.fill",           iconColor: UIColor(red:0.00,green:0.47,blue:0.83,alpha:1), iconBg: UIColor(red:0.00,green:0.47,blue:0.83,alpha:0.18), badge: nil),
        AITool(name: "Grok",       url: "https://grok.com",              icon: "bolt.fill",          iconColor: UIColor(red:0.85,green:0.85,blue:0.85,alpha:1), iconBg: UIColor.white.withAlphaComponent(0.10),             badge: nil),
        AITool(name: "Perplexity", url: "https://perplexity.ai",         icon: "magnifyingglass",    iconColor: UIColor(red:0.13,green:0.72,blue:0.73,alpha:1), iconBg: UIColor(red:0.13,green:0.72,blue:0.73,alpha:0.18), badge: nil),
        AITool(name: "DeepSeek",   url: "https://chat.deepseek.com",     icon: "brain.head.profile", iconColor: UIColor(red:0.47,green:0.39,blue:1.00,alpha:1), iconBg: UIColor(red:0.47,green:0.39,blue:1.00,alpha:0.18), badge: nil),
    ]
}

// ─────────────────────────────────────────
// MARK: - WallpaperManager
// ─────────────────────────────────────────
final class WallpaperManager {
    static let shared = WallpaperManager()
    private let keyWP  = "bvk_wallpaper_v1"
    private let keyDim = "bvk_dim_v1"

    let presets: [(name: String, start: UIColor, end: UIColor)] = [
        ("Vũ trụ",    UIColor(red:0.05,green:0.06,blue:0.10,alpha:1), UIColor(red:0.10,green:0.06,blue:0.18,alpha:1)),
        ("Đại dương", UIColor(red:0.00,green:0.12,blue:0.25,alpha:1), UIColor(red:0.00,green:0.20,blue:0.30,alpha:1)),
        ("Hoàng hôn", UIColor(red:0.10,green:0.04,blue:0.00,alpha:1), UIColor(red:0.24,green:0.10,blue:0.10,alpha:1)),
        ("Rừng đêm",  UIColor(red:0.00,green:0.10,blue:0.00,alpha:1), UIColor(red:0.04,green:0.10,blue:0.04,alpha:1)),
        ("Than hoa",  UIColor(red:0.05,green:0.05,blue:0.05,alpha:1), UIColor(red:0.10,green:0.10,blue:0.10,alpha:1)),
        ("Tím lạnh",  UIColor(red:0.05,green:0.00,blue:0.10,alpha:1), UIColor(red:0.10,green:0.00,blue:0.24,alpha:1)),
    ]

    var savedKey: String {
        get { UserDefaults.standard.string(forKey: keyWP) ?? "preset:0" }
        set { UserDefaults.standard.set(newValue, forKey: keyWP) }
    }
    var savedDim: Float {
        get { UserDefaults.standard.object(forKey: keyDim) == nil ? 0.45 : UserDefaults.standard.float(forKey: keyDim) }
        set { UserDefaults.standard.set(newValue, forKey: keyDim) }
    }

    func saveCustomImage(_ image: UIImage) {
        guard let data = image.jpegData(compressionQuality: 0.85) else { return }
        try? data.write(to: customURL)
        savedKey = "custom"
    }
    func loadCustomImage() -> UIImage? {
        guard let data = try? Data(contentsOf: customURL) else { return nil }
        return UIImage(data: data)
    }
    private var customURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("bvk_wallpaper.jpg")
    }
}

// ─────────────────────────────────────────
// MARK: - GradientBackgroundView
// ─────────────────────────────────────────
final class GradientBackgroundView: UIView {
    private let gradientLayer = CAGradientLayer()
    private let imageView     = UIImageView()
    private let dimView       = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        gradientLayer.startPoint = CGPoint(x: 0.2, y: 0)
        gradientLayer.endPoint   = CGPoint(x: 0.8, y: 1)
        layer.addSublayer(gradientLayer)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.alpha = 0
        addSubview(imageView)
        dimView.backgroundColor = .black
        addSubview(dimView)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        imageView.frame = bounds
        dimView.frame = bounds
    }

    func applyPreset(index: Int, dim: Float) {
        guard index < WallpaperManager.shared.presets.count else { return }
        let p = WallpaperManager.shared.presets[index]
        gradientLayer.colors = [p.start.cgColor, p.end.cgColor]
        UIView.animate(withDuration: 0.4) { self.imageView.alpha = 0 }
        dimView.alpha = CGFloat(dim)
    }

    func applyCustomImage(_ image: UIImage, dim: Float) {
        imageView.image = image
        UIView.animate(withDuration: 0.4) { self.imageView.alpha = 1 }
        dimView.alpha = CGFloat(dim)
    }

    func applyDim(_ dim: Float) { dimView.alpha = CGFloat(dim) }

    func applySaved() {
        let wm = WallpaperManager.shared
        let dim = wm.savedDim
        if wm.savedKey == "custom", let img = wm.loadCustomImage() {
            applyCustomImage(img, dim: dim)
        } else if wm.savedKey.hasPrefix("preset:"),
                  let idx = Int(wm.savedKey.dropFirst(7)) {
            applyPreset(index: idx, dim: dim)
        } else {
            applyPreset(index: 0, dim: dim)
        }
    }
}

// ─────────────────────────────────────────
// MARK: - AITableViewCell
// ─────────────────────────────────────────
final class AITableViewCell: UITableViewCell {
    private let cardView   = UIView()
    private let iconWrap   = UIView()
    private let iconImage  = UIImageView()
    private let nameLabel  = UILabel()
    private let urlLabel   = UILabel()
    private let badgeLabel = UILabel()
    private let chevron    = UIImageView(image: UIImage(systemName: "chevron.right"))

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle  = .none

        cardView.backgroundColor = .cardBg
        cardView.layer.cornerRadius = 16
        cardView.layer.borderWidth  = 0.5
        cardView.layer.borderColor  = UIColor.cardBorder.cgColor
        cardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cardView)

        iconWrap.layer.cornerRadius = 12
        iconWrap.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(iconWrap)

        iconImage.contentMode = .scaleAspectFit
        iconImage.translatesAutoresizingMaskIntoConstraints = false
        iconWrap.addSubview(iconImage)

        nameLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        nameLabel.textColor = .labelPrimary
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        urlLabel.font = .systemFont(ofSize: 12)
        urlLabel.textColor = .labelSub
        urlLabel.translatesAutoresizingMaskIntoConstraints = false

        badgeLabel.font = .systemFont(ofSize: 10, weight: .bold)
        badgeLabel.textColor = .accentBlue
        badgeLabel.backgroundColor = UIColor.accentBlue.withAlphaComponent(0.18)
        badgeLabel.layer.cornerRadius = 5
        badgeLabel.layer.masksToBounds = true
        badgeLabel.textAlignment = .center
        badgeLabel.isHidden = true
        badgeLabel.translatesAutoresizingMaskIntoConstraints = false

        chevron.tintColor = UIColor.white.withAlphaComponent(0.18)
        chevron.contentMode = .scaleAspectFit
        chevron.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        chevron.translatesAutoresizingMaskIntoConstraints = false

        let textStack = UIStackView(arrangedSubviews: [nameLabel, urlLabel])
        textStack.axis = .vertical; textStack.spacing = 2
        textStack.translatesAutoresizingMaskIntoConstraints = false

        cardView.addSubview(textStack)
        cardView.addSubview(badgeLabel)
        cardView.addSubview(chevron)

        NSLayoutConstraint.activate([
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            iconWrap.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 13),
            iconWrap.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            iconWrap.widthAnchor.constraint(equalToConstant: 40),
            iconWrap.heightAnchor.constraint(equalToConstant: 40),

            iconImage.centerXAnchor.constraint(equalTo: iconWrap.centerXAnchor),
            iconImage.centerYAnchor.constraint(equalTo: iconWrap.centerYAnchor),
            iconImage.widthAnchor.constraint(equalToConstant: 20),
            iconImage.heightAnchor.constraint(equalToConstant: 20),

            textStack.leadingAnchor.constraint(equalTo: iconWrap.trailingAnchor, constant: 12),
            textStack.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            textStack.trailingAnchor.constraint(lessThanOrEqualTo: badgeLabel.leadingAnchor, constant: -8),

            badgeLabel.trailingAnchor.constraint(equalTo: chevron.leadingAnchor, constant: -8),
            badgeLabel.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            badgeLabel.widthAnchor.constraint(equalToConstant: 34),
            badgeLabel.heightAnchor.constraint(equalToConstant: 18),

            chevron.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -14),
            chevron.centerYAnchor.constraint(equalTo: cardView.centerYAnchor),
            chevron.widthAnchor.constraint(equalToConstant: 12),
        ])
    }
    required init?(coder: NSCoder) { fatalError() }

    func configure(with tool: AITool) {
        nameLabel.text = tool.name
        urlLabel.text  = tool.url.replacingOccurrences(of: "https://", with: "")
        iconImage.image = UIImage(systemName: tool.icon)
        iconImage.tintColor = tool.iconColor
        iconWrap.backgroundColor = tool.iconBg
        if let badge = tool.badge {
            badgeLabel.text = badge
            badgeLabel.isHidden = false
        } else {
            badgeLabel.isHidden = true
        }
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        UIView.animate(withDuration: 0.12) {
            self.cardView.alpha = highlighted ? 0.55 : 1.0
            self.cardView.transform = highlighted ? CGAffineTransform(scaleX: 0.97, y: 0.97) : .identity
        }
    }
}

// ─────────────────────────────────────────
// MARK: - WallpaperPickerViewController
// ─────────────────────────────────────────
protocol WallpaperPickerDelegate: AnyObject {
    func wallpaperDidSelectPreset(_ index: Int)
    func wallpaperDidSelectCustom(_ image: UIImage)
    func wallpaperDidChangeDim(_ value: Float)
}

final class WallpaperPickerViewController: UIViewController {
    weak var delegate: WallpaperPickerDelegate?
    private var selectedPreset: Int = -1
    private var dimValue: Float = WallpaperManager.shared.savedDim
    private var thumbViews: [UIView] = []
    private let dimSlider = UISlider()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red:0.09,green:0.10,blue:0.13,alpha:0.98)
        view.layer.cornerRadius = 28
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        buildUI()
        // Restore current selection
        let key = WallpaperManager.shared.savedKey
        if key.hasPrefix("preset:"), let i = Int(key.dropFirst(7)) { highlight(i) }
    }

    private func buildUI() {
        // Handle bar
        let handle = UIView()
        handle.backgroundColor = UIColor.white.withAlphaComponent(0.22)
        handle.layer.cornerRadius = 2.5
        handle.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(handle)

        // Title
        let titleLbl = UILabel()
        titleLbl.text = "Hình nền"
        titleLbl.font = .systemFont(ofSize: 17, weight: .bold)
        titleLbl.textColor = .white
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleLbl)

        // Preset grid (2 rows × 3 cols)
        let grid = UIStackView()
        grid.axis = .horizontal; grid.spacing = 10; grid.distribution = .fillEqually
        grid.translatesAutoresizingMaskIntoConstraints = false
        let wm = WallpaperManager.shared
        for (i, preset) in wm.presets.enumerated() {
            let col = UIStackView(); col.axis = .vertical; col.spacing = 5; col.alignment = .center
            let thumb = UIView()
            thumb.layer.cornerRadius = 12; thumb.layer.masksToBounds = true
            thumb.tag = i
            let gl = CAGradientLayer()
            gl.colors = [preset.start.cgColor, preset.end.cgColor]
            gl.startPoint = CGPoint(x:0.2,y:0); gl.endPoint = CGPoint(x:0.8,y:1)
            thumb.layer.addSublayer(gl)
            thumb.heightAnchor.constraint(equalTo: thumb.widthAnchor, multiplier: 0.75).isActive = true
            let lbl = UILabel()
            lbl.text = preset.name; lbl.font = .systemFont(ofSize: 10, weight: .medium)
            lbl.textColor = UIColor.white.withAlphaComponent(0.45); lbl.textAlignment = .center
            col.addArrangedSubview(thumb)
            col.addArrangedSubview(lbl)
            let tap = UITapGestureRecognizer(target: self, action: #selector(presetTapped(_:)))
            thumb.addGestureRecognizer(tap)
            thumbViews.append(thumb)
            grid.addArrangedSubview(col)
            DispatchQueue.main.async { gl.frame = thumb.bounds }
        }
        view.addSubview(grid)

        // Dim slider row
        let sunL = UIImageView(image: UIImage(systemName: "sun.min.fill"))
        sunL.tintColor = UIColor.white.withAlphaComponent(0.35)
        sunL.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 13)
        let sunR = UIImageView(image: UIImage(systemName: "sun.max.fill"))
        sunR.tintColor = UIColor.white.withAlphaComponent(0.75)
        sunR.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 17)
        dimSlider.minimumValue = 0; dimSlider.maximumValue = 0.75; dimSlider.value = dimValue
        dimSlider.tintColor = .accentBlue
        dimSlider.addTarget(self, action: #selector(dimChanged), for: .valueChanged)
        let dimRow = UIStackView(arrangedSubviews: [sunL, dimSlider, sunR])
        dimRow.axis = .horizontal; dimRow.spacing = 10; dimRow.alignment = .center
        dimRow.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(dimRow)

        // Photo picker button
        var photoCfg = UIButton.Configuration.filled()
        photoCfg.title = "Tải ảnh từ thư viện"
        photoCfg.image = UIImage(systemName: "photo.on.rectangle")
        photoCfg.imagePadding = 8
        photoCfg.baseBackgroundColor = UIColor.white.withAlphaComponent(0.08)
        photoCfg.baseForegroundColor = UIColor.white.withAlphaComponent(0.65)
        photoCfg.cornerStyle = .large
        let photoBtn = UIButton(type: .system)
        photoBtn.configuration = photoCfg
        photoBtn.layer.borderWidth = 0.5
        photoBtn.layer.borderColor = UIColor.white.withAlphaComponent(0.14).cgColor
        photoBtn.layer.cornerRadius = 14
        photoBtn.addTarget(self, action: #selector(pickPhoto), for: .touchUpInside)
        photoBtn.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(photoBtn)

        // Done button
        var doneCfg = UIButton.Configuration.filled()
        doneCfg.title = "Xong"
        doneCfg.cornerStyle = .large
        doneCfg.baseBackgroundColor = .accentBlue
        doneCfg.baseForegroundColor = .white
        let doneBtn = UIButton(type: .system)
        doneBtn.configuration = doneCfg
        doneBtn.addTarget(self, action: #selector(done), for: .touchUpInside)
        doneBtn.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(doneBtn)

        NSLayoutConstraint.activate([
            handle.topAnchor.constraint(equalTo: view.topAnchor, constant: 10),
            handle.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            handle.widthAnchor.constraint(equalToConstant: 40),
            handle.heightAnchor.constraint(equalToConstant: 5),

            titleLbl.topAnchor.constraint(equalTo: handle.bottomAnchor, constant: 14),
            titleLbl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),

            grid.topAnchor.constraint(equalTo: titleLbl.bottomAnchor, constant: 16),
            grid.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            grid.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            dimRow.topAnchor.constraint(equalTo: grid.bottomAnchor, constant: 18),
            dimRow.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            dimRow.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            photoBtn.topAnchor.constraint(equalTo: dimRow.bottomAnchor, constant: 16),
            photoBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            photoBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            photoBtn.heightAnchor.constraint(equalToConstant: 46),

            doneBtn.topAnchor.constraint(equalTo: photoBtn.bottomAnchor, constant: 10),
            doneBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            doneBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            doneBtn.heightAnchor.constraint(equalToConstant: 50),
            doneBtn.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])
    }

    private func highlight(_ index: Int) {
        selectedPreset = index
        for (i, t) in thumbViews.enumerated() {
            t.layer.borderWidth = (i == index) ? 2 : 0
            t.layer.borderColor = UIColor.accentBlue.cgColor
        }
    }

    @objc private func presetTapped(_ tap: UITapGestureRecognizer) {
        guard let v = tap.view else { return }
        highlight(v.tag)
        WallpaperManager.shared.savedKey = "preset:\(v.tag)"
        delegate?.wallpaperDidSelectPreset(v.tag)
    }

    @objc private func dimChanged() {
        dimValue = dimSlider.value
        WallpaperManager.shared.savedDim = dimValue
        delegate?.wallpaperDidChangeDim(dimValue)
    }

    @objc private func pickPhoto() {
        var cfg = PHPickerConfiguration()
        cfg.selectionLimit = 1; cfg.filter = .images
        let picker = PHPickerViewController(configuration: cfg)
        picker.delegate = self
        present(picker, animated: true)
    }

    @objc private func done() {
        WallpaperManager.shared.savedDim = dimValue
        dismiss(animated: true)
    }
}

extension WallpaperPickerViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let provider = results.first?.itemProvider,
              provider.canLoadObject(ofClass: UIImage.self) else { return }
        provider.loadObject(ofClass: UIImage.self) { [weak self] obj, _ in
            guard let self = self, let image = obj as? UIImage else { return }
            WallpaperManager.shared.saveCustomImage(image)
            DispatchQueue.main.async {
                for t in self.thumbViews { t.layer.borderWidth = 0 }
                self.delegate?.wallpaperDidSelectCustom(image)
            }
        }
    }
}

// ─────────────────────────────────────────
// MARK: - HomeViewController
// ─────────────────────────────────────────
class HomeViewController: UIViewController {

    private let bgView        = GradientBackgroundView()
    private let tableView     = UITableView(frame: .zero, style: .plain)
    private let urlContainer  = UIView()
    private let urlField      = UITextField()
    private let goButton      = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = .black
        setupBackground()
        setupHeader()
        setupURLBar()
        setupTable()
    }

    // MARK: Background
    private func setupBackground() {
        bgView.frame = view.bounds
        bgView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.insertSubview(bgView, at: 0)
        bgView.applySaved()
    }

    // MARK: Header
    private var headerView = UIView()

    private func setupHeader() {
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)

        let attr = NSMutableAttributedString(
            string: "Custom",
            attributes: [.font: UIFont.systemFont(ofSize: 26, weight: .bold), .foregroundColor: UIColor.white])
        attr.append(NSAttributedString(
            string: "BVK",
            attributes: [.font: UIFont.systemFont(ofSize: 26, weight: .bold), .foregroundColor: UIColor.accentBlue]))
        let titleLbl = UILabel()
        titleLbl.attributedText = attr
        titleLbl.translatesAutoresizingMaskIntoConstraints = false
        headerView.addSubview(titleLbl)

        // Wallpaper btn
        let wpBtn = iconButton(systemName: "photo.circle.fill", size: 28)
        wpBtn.addTarget(self, action: #selector(openWallpaper), for: .touchUpInside)
        headerView.addSubview(wpBtn)

        // About btn
        let aboutBtn = iconButton(systemName: "person.circle.fill", size: 28)
        aboutBtn.addTarget(self, action: #selector(openAbout), for: .touchUpInside)
        headerView.addSubview(aboutBtn)

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 6),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 18),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -18),
            headerView.heightAnchor.constraint(equalToConstant: 44),

            titleLbl.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            titleLbl.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            aboutBtn.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            aboutBtn.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            aboutBtn.widthAnchor.constraint(equalToConstant: 36),
            aboutBtn.heightAnchor.constraint(equalToConstant: 36),

            wpBtn.trailingAnchor.constraint(equalTo: aboutBtn.leadingAnchor, constant: -6),
            wpBtn.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            wpBtn.widthAnchor.constraint(equalToConstant: 36),
            wpBtn.heightAnchor.constraint(equalToConstant: 36),
        ])
    }

    private func iconButton(systemName: String, size: CGFloat) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: systemName,
            withConfiguration: UIImage.SymbolConfiguration(pointSize: size, weight: .regular)), for: .normal)
        btn.tintColor = UIColor.white.withAlphaComponent(0.65)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }

    // MARK: URL Bar
    private func setupURLBar() {
        urlContainer.backgroundColor = UIColor.white.withAlphaComponent(0.09)
        urlContainer.layer.cornerRadius = 14
        urlContainer.layer.borderWidth  = 0.5
        urlContainer.layer.borderColor  = UIColor.white.withAlphaComponent(0.14).cgColor
        urlContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(urlContainer)

        let linkIcon = UIImageView(image: UIImage(systemName: "link",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)))
        linkIcon.tintColor = UIColor.white.withAlphaComponent(0.28)
        linkIcon.contentMode = .scaleAspectFit
        linkIcon.translatesAutoresizingMaskIntoConstraints = false
        urlContainer.addSubview(linkIcon)

        urlField.keyboardType = .URL
        urlField.autocapitalizationType = .none
        urlField.autocorrectionType = .no
        urlField.returnKeyType = .go
        urlField.clearButtonMode = .whileEditing
        urlField.delegate = self
        urlField.textColor = .white
        urlField.tintColor = .accentBlue
        urlField.attributedPlaceholder = NSAttributedString(
            string: "Dán link bất kỳ…",
            attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.28)])
        urlField.translatesAutoresizingMaskIntoConstraints = false
        urlContainer.addSubview(urlField)

        urlField.addTarget(self, action: #selector(urlFocused), for: .editingDidBegin)
        urlField.addTarget(self, action: #selector(urlBlurred), for: .editingDidEnd)

        var goConfig = UIButton.Configuration.filled()
        goConfig.image = UIImage(systemName: "arrow.right",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold))
        goConfig.baseBackgroundColor = .accentBlue
        goConfig.baseForegroundColor = .white
        goConfig.cornerStyle = .medium
        goButton.configuration = goConfig
        goButton.addTarget(self, action: #selector(openURL), for: .touchUpInside)
        goButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(goButton)

        NSLayoutConstraint.activate([
            urlContainer.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 12),
            urlContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            urlContainer.trailingAnchor.constraint(equalTo: goButton.leadingAnchor, constant: -8),
            urlContainer.heightAnchor.constraint(equalToConstant: 46),

            linkIcon.leadingAnchor.constraint(equalTo: urlContainer.leadingAnchor, constant: 12),
            linkIcon.centerYAnchor.constraint(equalTo: urlContainer.centerYAnchor),
            linkIcon.widthAnchor.constraint(equalToConstant: 16),

            urlField.leadingAnchor.constraint(equalTo: linkIcon.trailingAnchor, constant: 8),
            urlField.trailingAnchor.constraint(equalTo: urlContainer.trailingAnchor, constant: -8),
            urlField.topAnchor.constraint(equalTo: urlContainer.topAnchor),
            urlField.bottomAnchor.constraint(equalTo: urlContainer.bottomAnchor),

            goButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            goButton.centerYAnchor.constraint(equalTo: urlContainer.centerYAnchor),
            goButton.widthAnchor.constraint(equalToConstant: 46),
            goButton.heightAnchor.constraint(equalToConstant: 46),
        ])
    }

    @objc private func urlFocused() {
        UIView.animate(withDuration: 0.2) {
            self.urlContainer.layer.borderColor = UIColor.accentBlue.withAlphaComponent(0.55).cgColor
            self.urlContainer.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        }
    }
    @objc private func urlBlurred() {
        UIView.animate(withDuration: 0.2) {
            self.urlContainer.layer.borderColor = UIColor.white.withAlphaComponent(0.14).cgColor
            self.urlContainer.backgroundColor = UIColor.white.withAlphaComponent(0.09)
        }
    }

    // MARK: Table
    private func setupTable() {
        tableView.backgroundColor = .clear
        tableView.separatorStyle  = .none
        tableView.rowHeight = 64
        tableView.showsVerticalScrollIndicator = false
        tableView.keyboardDismissMode = .onDrag
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        tableView.delegate   = self
        tableView.dataSource = self
        tableView.register(AITableViewCell.self, forCellReuseIdentifier: "AICell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        // Section header
        let headerH = UIView(frame: CGRect(x:0,y:0,width:UIScreen.main.bounds.width,height:38))
        let secLbl = UILabel()
        secLbl.text = "CHỌN LINK"
        secLbl.font = .systemFont(ofSize: 11, weight: .semibold)
        secLbl.textColor = UIColor.white.withAlphaComponent(0.32)
        let kern: CGFloat = 1.0
        let attr = NSAttributedString(string: "CHỌN LINK", attributes: [
            .kern: kern, .font: secLbl.font as Any, .foregroundColor: secLbl.textColor as Any])
        secLbl.attributedText = attr
        secLbl.translatesAutoresizingMaskIntoConstraints = false
        headerH.addSubview(secLbl)
        NSLayoutConstraint.activate([
            secLbl.leadingAnchor.constraint(equalTo: headerH.leadingAnchor, constant: 20),
            secLbl.centerYAnchor.constraint(equalTo: headerH.centerYAnchor),
        ])
        tableView.tableHeaderView = headerH

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: urlContainer.bottomAnchor, constant: 4),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    // MARK: Actions
    @objc private func dismissKeyboard() { view.endEditing(true) }

    @objc func openURL() {
        guard var raw = urlField.text?.trimmingCharacters(in: .whitespaces), !raw.isEmpty else { return }
        if !raw.hasPrefix("http") { raw = "https://" + raw }
        guard let url = URL(string: raw) else { return }
        urlField.resignFirstResponder()
        pushWeb(url: url, title: url.host ?? raw)
    }

    @objc private func openWallpaper() {
        let vc = WallpaperPickerViewController()
        vc.delegate = self
        vc.modalPresentationStyle = .pageSheet
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.prefersGrabberVisible = false
            sheet.preferredCornerRadius = 28
        }
        present(vc, animated: true)
    }

    @objc private func openAbout() {
        let vc = AboutViewController()
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .pageSheet
        present(nav, animated: true)
    }

    func pushWeb(url: URL, title: String) {
        let vc = WebViewController(url: url, pageTitle: title)
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: WallpaperPickerDelegate
extension HomeViewController: WallpaperPickerDelegate {
    func wallpaperDidSelectPreset(_ index: Int) {
        bgView.applyPreset(index: index, dim: WallpaperManager.shared.savedDim)
    }
    func wallpaperDidSelectCustom(_ image: UIImage) {
        bgView.applyCustomImage(image, dim: WallpaperManager.shared.savedDim)
    }
    func wallpaperDidChangeDim(_ value: Float) {
        bgView.applyDim(value)
    }
}

// MARK: TableView
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tv: UITableView, numberOfRowsInSection s: Int) -> Int { AITools.list.count }
    func tableView(_ tv: UITableView, cellForRowAt ip: IndexPath) -> UITableViewCell {
        let cell = tv.dequeueReusableCell(withIdentifier: "AICell", for: ip) as! AITableViewCell
        cell.configure(with: AITools.list[ip.row])
        return cell
    }
    func tableView(_ tv: UITableView, didSelectRowAt ip: IndexPath) {
        tv.deselectRow(at: ip, animated: false)
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
    private let progressBar  = UIProgressView(progressViewStyle: .bar)
    private var kvoToken: NSKeyValueObservation?
    private var retryCount   = 0
    private let maxRetry     = 2
    private let url: URL
    private let pageTitle: String
    private let networkMonitor   = NWPathMonitor()
    private var isNetworkAvailable = true

    init(url: URL, pageTitle: String) {
        self.url = url; self.pageTitle = pageTitle
        super.init(nibName: nil, bundle: nil)
        hidesBottomBarWhenPushed = true
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = pageTitle
        view.backgroundColor = .black
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.tintColor = .accentBlue
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.clockwise"),
            style: .plain, target: self, action: #selector(reload))
        setupWebView()
        setupProgressBar()
        startNetworkMonitor()
        syncCookiesThenLoad()
    }

    deinit {
        kvoToken?.invalidate()
        networkMonitor.cancel()
        webView?.navigationDelegate = nil
        webView?.uiDelegate = nil
        webView?.stopLoading()
    }

    private func setupWebView() {
        let cfg = WKWebViewConfiguration()
        cfg.allowsInlineMediaPlayback = true
        cfg.mediaTypesRequiringUserActionForPlayback = []
        cfg.websiteDataStore = WKWebsiteDataStore.default()
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        cfg.defaultWebpagePreferences = prefs
        webView = WKWebView(frame: .zero, configuration: cfg)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.decelerationRate = .normal
        webView.scrollView.contentInsetAdjustmentBehavior = .automatic
        webView.customUserAgent =
            "Mozilla/5.0 (iPhone; CPU iPhone OS 16_6 like Mac OS X) " +
            "AppleWebKit/605.1.15 (KHTML, like Gecko) " +
            "Version/16.6 Mobile/15E148 Safari/604.1"
        view.addSubview(webView)
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func setupProgressBar() {
        progressBar.progressTintColor = .accentBlue
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
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                let p = Float(wv.estimatedProgress)
                self.progressBar.setProgress(p, animated: true)
                self.progressBar.isHidden = p >= 1.0
            }
        }
    }

    private func startNetworkMonitor() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async { [weak self] in
                self?.isNetworkAvailable = (path.status == .satisfied)
            }
        }
        networkMonitor.start(queue: DispatchQueue(label: "bvk.network"))
    }

    func syncCookiesThenLoad() {
        let store = WKWebsiteDataStore.default().httpCookieStore
        let safari = HTTPCookieStorage.shared.cookies ?? []
        let g = DispatchGroup()
        for c in safari { g.enter(); store.setCookie(c) { g.leave() } }
        g.enter()
        store.getAllCookies { cookies in
            for c in cookies { HTTPCookieStorage.shared.setCookie(c) }
            g.leave()
        }
        g.notify(queue: .main) { [weak self] in self?.loadPage() }
    }

    func persistCookiesToSafari() {
        WKWebsiteDataStore.default().httpCookieStore.getAllCookies { cookies in
            for c in cookies { HTTPCookieStorage.shared.setCookie(c) }
        }
    }

    func loadPage() {
        guard isNetworkAvailable else { showNoNetworkAlert(); return }
        retryCount = 0
        var req = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 15)
        req.setValue(webView.customUserAgent, forHTTPHeaderField: "User-Agent")
        webView.load(req)
    }

    @objc func reload() {
        guard isNetworkAvailable else { showNoNetworkAlert(); return }
        retryCount = 0; webView.reload()
    }

    func showNoNetworkAlert() {
        let a = UIAlertController(title: "Không có mạng", message: "Kiểm tra Wi-Fi hoặc 4G rồi thử lại.", preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "Thử lại", style: .default) { [weak self] _ in self?.loadPage() })
        a.addAction(UIAlertAction(title: "Huỷ", style: .cancel))
        present(a, animated: true)
    }
}

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        retryCount = 0
        progressBar.isHidden = true; progressBar.setProgress(0, animated: false)
        if let t = webView.title, !t.isEmpty { title = t }
        persistCookiesToSafari()
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) { handleError(error) }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation nav: WKNavigation!, withError error: Error) {
        guard (error as NSError).code != NSURLErrorCancelled else { return }
        handleError(error)
    }
    func handleError(_ error: Error) {
        progressBar.isHidden = true
        if !isNetworkAvailable { showNoNetworkAlert(); return }
        if retryCount < maxRetry {
            retryCount += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in self?.webView.reload() }
            return
        }
        let a = UIAlertController(title: "Không tải được", message: "Kiểm tra mạng rồi thử lại.", preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "Thử lại", style: .default) { [weak self] _ in self?.loadPage() })
        a.addAction(UIAlertAction(title: "Huỷ", style: .cancel))
        present(a, animated: true)
    }
    func webView(_ webView: WKWebView, decidePolicyFor action: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = action.request.url, ["https","http","about"].contains(url.scheme ?? "") else { decisionHandler(.cancel); return }
        decisionHandler(.allow)
    }
    func webViewWebContentProcessDidTerminate(_ webView: WKWebView) { retryCount = 0; webView.reload() }
}

extension WebViewController: WKUIDelegate {
    func webView(_ webView: WKWebView,
                 requestMediaCapturePermissionFor origin: WKSecurityOrigin,
                 initiatedByFrame frame: WKFrameInfo,
                 type: WKMediaCaptureType,
                 decisionHandler: @escaping (WKPermissionDecision) -> Void) {
        let name: String
        switch type {
        case .camera: name = "camera"
        case .microphone: name = "microphone"
        case .cameraAndMicrophone: name = "camera và microphone"
        @unknown default: name = "thiết bị"
        }
        let a = UIAlertController(title: "Yêu cầu quyền", message: "\(origin.host) muốn dùng \(name).", preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "Cho phép", style: .default) { _ in decisionHandler(.grant) })
        a.addAction(UIAlertAction(title: "Từ chối", style: .cancel)  { _ in decisionHandler(.deny) })
        present(a, animated: true)
    }
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let a = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK", style: .default) { _ in completionHandler() })
        present(a, animated: true)
    }
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let a = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "OK",  style: .default) { _ in completionHandler(true) })
        a.addAction(UIAlertAction(title: "Huỷ", style: .cancel)  { _ in completionHandler(false) })
        present(a, animated: true)
    }
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
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
        view.backgroundColor = UIColor(red:0.07,green:0.08,blue:0.10,alpha:1)
        navigationController?.navigationBar.tintColor = .accentBlue
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationController?.navigationBar.barStyle = .black
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(close))
        buildUI()
    }

    @objc private func close() { dismiss(animated: true) }

    private func buildUI() {
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
        root.axis = .vertical; root.alignment = .center; root.spacing = 16
        root.translatesAutoresizingMaskIntoConstraints = false
        scroll.addSubview(root)
        NSLayoutConstraint.activate([
            root.topAnchor.constraint(equalTo: scroll.topAnchor, constant: 36),
            root.leadingAnchor.constraint(equalTo: scroll.leadingAnchor, constant: 20),
            root.trailingAnchor.constraint(equalTo: scroll.trailingAnchor, constant: -20),
            root.bottomAnchor.constraint(equalTo: scroll.bottomAnchor, constant: -40),
            root.widthAnchor.constraint(equalTo: scroll.widthAnchor, constant: -40),
        ])

        // Avatar
        let ring = UIView()
        ring.layer.cornerRadius = 48
        ring.layer.borderWidth  = 1.5
        ring.layer.borderColor  = UIColor.accentBlue.withAlphaComponent(0.4).cgColor
        ring.backgroundColor    = UIColor.accentBlue.withAlphaComponent(0.08)
        ring.widthAnchor.constraint(equalToConstant: 96).isActive = true
        ring.heightAnchor.constraint(equalToConstant: 96).isActive = true
        let iconIV = UIImageView(image: UIImage(systemName: "person.2.circle.fill",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 58, weight: .regular)))
        iconIV.tintColor = .accentBlue; iconIV.contentMode = .scaleAspectFit
        iconIV.translatesAutoresizingMaskIntoConstraints = false
        ring.addSubview(iconIV)
        NSLayoutConstraint.activate([
            iconIV.centerXAnchor.constraint(equalTo: ring.centerXAnchor),
            iconIV.centerYAnchor.constraint(equalTo: ring.centerYAnchor),
            iconIV.widthAnchor.constraint(equalToConstant: 64),
            iconIV.heightAnchor.constraint(equalToConstant: 64),
        ])

        let appAttr = NSMutableAttributedString(
            string: "Custom",
            attributes: [.font: UIFont.systemFont(ofSize: 24, weight: .bold), .foregroundColor: UIColor.white])
        appAttr.append(NSAttributedString(
            string: "BVK",
            attributes: [.font: UIFont.systemFont(ofSize: 24, weight: .bold), .foregroundColor: UIColor.accentBlue]))
        let appLbl = UILabel(); appLbl.attributedText = appAttr
        let verLbl = mkLbl("Phiên bản 1.0 · iOS 15+", size: 13, color: UIColor.white.withAlphaComponent(0.35))

        let devCard = glassCard()
        let devStack = vstack(12); devCard.addSubview(devStack); pin(devStack, to: devCard)
        devStack.addArrangedSubview(sectionHeader("Nhà phát triển", icon: "person.2.fill"))
        devStack.addArrangedSubview(sep())
        devStack.addArrangedSubview(devRow("Văn Khoa", role: "Developer"))
        devStack.addArrangedSubview(sep())
        devStack.addArrangedSubview(devRow("Cao Long", role: "Developer"))

        let contactCard = glassCard()
        let contactStack = vstack(12); contactCard.addSubview(contactStack); pin(contactStack, to: contactCard)
        contactStack.addArrangedSubview(sectionHeader("Liên hệ", icon: "envelope.fill"))
        contactStack.addArrangedSubview(sep())
        let emailBtn = UIButton(type: .system)
        emailBtn.setTitle("tranvantrinhhd@gmail.com", for: .normal)
        emailBtn.setTitleColor(.accentBlue, for: .normal)
        emailBtn.titleLabel?.font = .systemFont(ofSize: 14)
        emailBtn.contentHorizontalAlignment = .left
        emailBtn.addTarget(self, action: #selector(mailTap), for: .touchUpInside)
        contactStack.addArrangedSubview(emailBtn)

        let copyLbl = mkLbl("© 2025 Văn Khoa & Cao Long\nAll rights reserved.", size: 11, color: UIColor.white.withAlphaComponent(0.2))
        copyLbl.numberOfLines = 0; copyLbl.textAlignment = .center

        root.addArrangedSubview(ring)
        root.addArrangedSubview(appLbl)
        root.addArrangedSubview(verLbl)
        root.setCustomSpacing(24, after: verLbl)
        root.addArrangedSubview(devCard)
        root.addArrangedSubview(contactCard)
        root.setCustomSpacing(24, after: contactCard)
        root.addArrangedSubview(copyLbl)
    }

    private func mkLbl(_ t: String, size: CGFloat, color: UIColor = .white) -> UILabel {
        let l = UILabel(); l.text = t; l.font = .systemFont(ofSize: size); l.textColor = color; return l
    }
    private func sectionHeader(_ text: String, icon: String) -> UIView {
        let row = UIStackView(); row.axis = .horizontal; row.spacing = 7; row.alignment = .center
        let iv = UIImageView(image: UIImage(systemName: icon,
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)))
        iv.tintColor = .accentBlue; iv.contentMode = .scaleAspectFit
        iv.widthAnchor.constraint(equalToConstant: 14).isActive = true
        let l = mkLbl(text.uppercased(), size: 11, color: .accentBlue)
        row.addArrangedSubview(iv); row.addArrangedSubview(l); return row
    }
    private func devRow(_ name: String, role: String) -> UIView {
        let row = UIStackView(); row.axis = .horizontal; row.alignment = .center
        let n = UILabel(); n.text = name; n.font = .systemFont(ofSize: 15, weight: .medium); n.textColor = .white
        let r = mkLbl(role, size: 12, color: UIColor.white.withAlphaComponent(0.35))
        row.addArrangedSubview(n); row.addArrangedSubview(UIView()); row.addArrangedSubview(r); return row
    }
    private func sep() -> UIView {
        let v = UIView(); v.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        v.heightAnchor.constraint(equalToConstant: 0.5).isActive = true; return v
    }
    private func glassCard() -> UIView {
        let v = UIView()
        v.backgroundColor = UIColor.white.withAlphaComponent(0.07)
        v.layer.cornerRadius = 16
        v.layer.borderWidth  = 0.5
        v.layer.borderColor  = UIColor.white.withAlphaComponent(0.10).cgColor
        v.translatesAutoresizingMaskIntoConstraints = false
        v.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width - 40).isActive = true
        return v
    }
    private func vstack(_ spacing: CGFloat) -> UIStackView {
        let s = UIStackView(); s.axis = .vertical; s.spacing = spacing
        s.translatesAutoresizingMaskIntoConstraints = false; return s
    }
    private func pin(_ child: UIView, to parent: UIView) {
        NSLayoutConstraint.activate([
            child.topAnchor.constraint(equalTo: parent.topAnchor, constant: 16),
            child.leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: 16),
            child.trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: -16),
            child.bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: -16),
        ])
    }
    @objc private func mailTap() {
        if let url = URL(string: "mailto:tranvantrinhhd@gmail.com") { UIApplication.shared.open(url) }
    }
}

// ─────────────────────────────────────────
typealias ViewController = HomeViewController

// ─────────────────────────────────────────
// MARK: - Info.plist — PHẢI THÊM 3 KEY NÀY
// ─────────────────────────────────────────
/*
 <key>NSCameraUsageDescription</key>
 <string>Dùng camera để chụp tài liệu, bài tập cho AI phân tích</string>

 <key>NSMicrophoneUsageDescription</key>
 <string>Dùng microphone để nhập liệu giọng nói cho AI</string>

 <key>NSPhotoLibraryUsageDescription</key>
 <string>Chọn ảnh từ thư viện làm hình nền ứng dụng</string>
 */
