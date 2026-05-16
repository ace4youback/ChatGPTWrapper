import UIKit
import WebKit
import Network
import PhotosUI
import AVKit

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
    private let chevron    = UIImageView(image: UIImage(systemName: "chevron.right", withConfiguration: UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)))

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle  = .none

        // iOS 15: phải set rõ background cho contentView, không để hệ thống override
        contentView.backgroundColor = .clear
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
        // preferredSymbolConfiguration moved to image init for iOS 15 compat
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
            badgeLabel.text = badge; badgeLabel.isHidden = false
        } else { badgeLabel.isHidden = true }
    }

    // ✅ Configure từ Bookmark (dùng hex colors)
    func configureBM(_ bm: Bookmark) {
        nameLabel.text  = bm.name
        urlLabel.text   = bm.url.replacingOccurrences(of: "https://", with: "")
        iconImage.image = UIImage(systemName: bm.iconName)
        iconImage.tintColor      = UIColor(hex: bm.iconColorHex)
        iconWrap.backgroundColor = UIColor(hex: bm.iconBgHex)
        if let badge = bm.badge {
            badgeLabel.text = badge; badgeLabel.isHidden = false
        } else { badgeLabel.isHidden = true }
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
        let sunL = UIImageView(image: UIImage(systemName: "sun.min.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 13)))
        sunL.tintColor = UIColor.white.withAlphaComponent(0.35)
        // sunL config inline
        let sunR = UIImageView(image: UIImage(systemName: "sun.max.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 17)))
        sunR.tintColor = UIColor.white.withAlphaComponent(0.75)
        // sunR config inline
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
// MARK: - BookmarkStore  (UserDefaults · Codable)
// ─────────────────────────────────────────
struct Bookmark: Codable, Equatable {
    var id: String      = UUID().uuidString
    var name: String
    var url: String
    var isBuiltIn: Bool
    var iconName: String
    var iconColorHex: String
    var iconBgHex: String
    var badge: String?
}

final class BookmarkStore {
    static let shared = BookmarkStore()
    private let udKey = "bvk_bookmarks_v2"

    private let builtIns: [Bookmark] = [
        // ── YouTube & Entertainment (ưu tiên đầu)
        Bookmark(name:"YouTube",    url:"https://m.youtube.com",         isBuiltIn:true,  iconName:"play.rectangle.fill",iconColorHex:"#FF0000", iconBgHex:"#FF000030", badge:"HOT"),
        Bookmark(name:"YouTube Music",url:"https://music.youtube.com",   isBuiltIn:true,  iconName:"music.note",         iconColorHex:"#FF0000", iconBgHex:"#FF000022", badge:nil),
        Bookmark(name:"Netflix",    url:"https://www.netflix.com",       isBuiltIn:true,  iconName:"tv.fill",            iconColorHex:"#E50914", iconBgHex:"#E5091422", badge:nil),
        Bookmark(name:"TikTok",     url:"https://www.tiktok.com",        isBuiltIn:true,  iconName:"video.fill",         iconColorHex:"#69C9D0", iconBgHex:"#69C9D022", badge:nil),
        // ── AI Tools
        Bookmark(name:"ChatGPT",    url:"https://chat.openai.com",       isBuiltIn:true,  iconName:"message.fill",       iconColorHex:"#10A37F", iconBgHex:"#10A37F30", badge:nil),
        Bookmark(name:"Claude",     url:"https://claude.ai",             isBuiltIn:true,  iconName:"sparkles",           iconColorHex:"#CC8C5A", iconBgHex:"#CC8C5A30", badge:nil),
        Bookmark(name:"Gemini",     url:"https://gemini.google.com",     isBuiltIn:true,  iconName:"diamond.fill",       iconColorHex:"#4285F4", iconBgHex:"#4285F430", badge:nil),
        Bookmark(name:"Copilot",    url:"https://copilot.microsoft.com", isBuiltIn:true,  iconName:"cpu.fill",           iconColorHex:"#0078D4", iconBgHex:"#0078D430", badge:nil),
        Bookmark(name:"Grok",       url:"https://grok.com",              isBuiltIn:true,  iconName:"bolt.fill",          iconColorHex:"#DDDDDD", iconBgHex:"#FFFFFF1A", badge:nil),
        Bookmark(name:"Perplexity", url:"https://perplexity.ai",         isBuiltIn:true,  iconName:"magnifyingglass",    iconColorHex:"#20B8BA", iconBgHex:"#20B8BA30", badge:nil),
        Bookmark(name:"DeepSeek",   url:"https://chat.deepseek.com",     isBuiltIn:true,  iconName:"brain.head.profile", iconColorHex:"#7864FF", iconBgHex:"#7864FF30", badge:nil),
    ]

    private var custom: [Bookmark] {
        get {
            guard let d = UserDefaults.standard.data(forKey: udKey),
                  let arr = try? JSONDecoder().decode([Bookmark].self, from: d) else { return [] }
            return arr
        }
        set {
            if let d = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(d, forKey: udKey)
            }
        }
    }

    var all: [Bookmark] { builtIns + custom }

    func add(_ bm: Bookmark) { var c = custom; c.append(bm); custom = c }
    func remove(id: String)  { custom = custom.filter { $0.id != id } }
    func contains(url: String) -> Bool { all.contains { $0.url == url } }
}

// Hex → UIColor
extension UIColor {
    convenience init(hex: String) {
        var h = hex.trimmingCharacters(in: CharacterSet(charactersIn: "#"))
        if h.count == 6 { h += "FF" }
        let v = UInt64(h, radix: 16) ?? 0xFFFFFFFF
        self.init(red:   CGFloat((v >> 24) & 0xFF) / 255,
                  green: CGFloat((v >> 16) & 0xFF) / 255,
                  blue:  CGFloat((v >>  8) & 0xFF) / 255,
                  alpha: CGFloat( v        & 0xFF) / 255)
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

        // ✅ Nút lưu bookmark bên cạnh nút Go
        let saveBtn = UIButton(type: .system)
        var saveCfg = UIButton.Configuration.filled()
        saveCfg.image = UIImage(systemName: "bookmark.fill",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 13, weight: .semibold))
        saveCfg.baseBackgroundColor = UIColor.white.withAlphaComponent(0.10)
        saveCfg.baseForegroundColor = UIColor.accentBlue
        saveCfg.cornerStyle = .medium
        saveBtn.configuration = saveCfg
        saveBtn.layer.borderWidth = 0.5
        saveBtn.layer.cornerRadius = 10
        saveBtn.layer.borderColor = UIColor.accentBlue.withAlphaComponent(0.25).cgColor
        saveBtn.addTarget(self, action: #selector(saveBookmark), for: .touchUpInside)
        saveBtn.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(saveBtn)

        NSLayoutConstraint.activate([
            urlContainer.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 12),
            urlContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            urlContainer.trailingAnchor.constraint(equalTo: saveBtn.leadingAnchor, constant: -7),
            urlContainer.heightAnchor.constraint(equalToConstant: 46),

            linkIcon.leadingAnchor.constraint(equalTo: urlContainer.leadingAnchor, constant: 12),
            linkIcon.centerYAnchor.constraint(equalTo: urlContainer.centerYAnchor),
            linkIcon.widthAnchor.constraint(equalToConstant: 16),

            urlField.leadingAnchor.constraint(equalTo: linkIcon.trailingAnchor, constant: 8),
            urlField.trailingAnchor.constraint(equalTo: urlContainer.trailingAnchor, constant: -8),
            urlField.topAnchor.constraint(equalTo: urlContainer.topAnchor),
            urlField.bottomAnchor.constraint(equalTo: urlContainer.bottomAnchor),

            saveBtn.trailingAnchor.constraint(equalTo: goButton.leadingAnchor, constant: -7),
            saveBtn.centerYAnchor.constraint(equalTo: urlContainer.centerYAnchor),
            saveBtn.widthAnchor.constraint(equalToConstant: 40),
            saveBtn.heightAnchor.constraint(equalToConstant: 40),

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
        // iOS 15: tắt section highlight mặc định
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        tableView.delegate   = self
        tableView.dataSource = self
        tableView.register(AITableViewCell.self, forCellReuseIdentifier: "AICell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)

        // Section header
        let headerH = UIView(frame: CGRect(x:0,y:0,width:UIScreen.main.bounds.width,height:38))
        let secLbl = UILabel()
        secLbl.text = "YOUTUBE & AI"
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

    // ✅ Lưu bookmark từ URL bar
    @objc func saveBookmark() {
        guard var raw = urlField.text?.trimmingCharacters(in: .whitespaces), !raw.isEmpty else {
            let a = UIAlertController(title: nil, message: "Nhập link trước khi lưu.", preferredStyle: .alert)
            a.addAction(UIAlertAction(title: "OK", style: .default)); present(a, animated: true); return
        }
        if !raw.hasPrefix("http") { raw = "https://" + raw }
        guard URL(string: raw) != nil else { return }
        if BookmarkStore.shared.contains(url: raw) {
            let a = UIAlertController(title: "Đã lưu rồi", message: "Link này đã có trong danh sách.", preferredStyle: .alert)
            a.addAction(UIAlertAction(title: "OK", style: .default)); present(a, animated: true); return
        }
        let alert = UIAlertController(title: "Lưu vào yêu thích", message: "Đặt tên cho link:", preferredStyle: .alert)
        alert.addTextField { tf in
            tf.placeholder = "Tên hiển thị"
            tf.text = URL(string: raw)?.host ?? raw
            tf.autocapitalizationType = .words
        }
        alert.addAction(UIAlertAction(title: "Huỷ", style: .cancel))
        alert.addAction(UIAlertAction(title: "Lưu", style: .default) { [weak self] _ in
            let name = alert.textFields?.first?.text?.trimmingCharacters(in: .whitespaces) ?? (URL(string: raw)?.host ?? raw)
            let bm = Bookmark(name: name, url: raw, isBuiltIn: false,
                              iconName: "star.fill", iconColorHex: "#FFD700", iconBgHex: "#FFD70030", badge: nil)
            BookmarkStore.shared.add(bm)
            self?.tableView.reloadData()
            self?.showToast("Đã lưu \"\(name)\"")
        })
        present(alert, animated: true)
    }

    private func showToast(_ msg: String) {
        let t = UILabel()
        t.text = "  \(msg)  "
        t.font = .systemFont(ofSize: 13, weight: .medium)
        t.textColor = .white; t.textAlignment = .center
        t.backgroundColor = UIColor.black.withAlphaComponent(0.72)
        t.layer.cornerRadius = 14; t.layer.masksToBounds = true
        t.layer.borderWidth = 0.5; t.layer.borderColor = UIColor.white.withAlphaComponent(0.14).cgColor
        t.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(t)
        NSLayoutConstraint.activate([
            t.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            t.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80),
            t.heightAnchor.constraint(equalToConstant: 38),
        ])
        t.alpha = 0
        UIView.animate(withDuration: 0.2) { t.alpha = 1 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            UIView.animate(withDuration: 0.3, animations: { t.alpha = 0 }) { _ in t.removeFromSuperview() }
        }
    }

    @objc private func openWallpaper() {
        let vc = WallpaperPickerViewController()
        vc.delegate = self
        if #available(iOS 16.0, *) {
            vc.modalPresentationStyle = .pageSheet
            if let sheet = vc.sheetPresentationController {
                sheet.detents = [.medium()]
                sheet.prefersGrabberVisible = false
                sheet.preferredCornerRadius = 28
            }
        } else {
            vc.modalPresentationStyle = .formSheet
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
        vc.onBookmarkToggle = { [weak self] in self?.tableView.reloadData() }
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

// MARK: TableView — dùng BookmarkStore
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tv: UITableView, numberOfRowsInSection s: Int) -> Int {
        BookmarkStore.shared.all.count
    }
    func tableView(_ tv: UITableView, cellForRowAt ip: IndexPath) -> UITableViewCell {
        let cell = tv.dequeueReusableCell(withIdentifier: "AICell", for: ip) as! AITableViewCell
        cell.configureBM(BookmarkStore.shared.all[ip.row])
        return cell
    }
    func tableView(_ tv: UITableView, didSelectRowAt ip: IndexPath) {
        tv.deselectRow(at: ip, animated: false)
        let bm = BookmarkStore.shared.all[ip.row]
        guard let url = URL(string: bm.url) else { return }
        pushWeb(url: url, title: bm.name)
    }
    // Swipe-to-delete — chỉ custom bookmark
    func tableView(_ tv: UITableView, trailingSwipeActionsConfigurationForRowAt ip: IndexPath) -> UISwipeActionsConfiguration? {
        let bm = BookmarkStore.shared.all[ip.row]
        guard !bm.isBuiltIn else { return nil }
        let del = UIContextualAction(style: .destructive, title: "Xoá") { _, _, done in
            BookmarkStore.shared.remove(id: bm.id)
            tv.deleteRows(at: [ip], with: .fade)
            done(true)
        }
        del.image = UIImage(systemName: "trash")
        return UISwipeActionsConfiguration(actions: [del])
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
    private let progressBar     = UIProgressView(progressViewStyle: .bar)
    private var kvoToken: NSKeyValueObservation?
    private var retryCount      = 0
    private let maxRetry        = 2
    private let url: URL
    private let pageTitle: String
    private let networkMonitor  = NWPathMonitor()
    private var isNetworkAvailable = true

    // ✅ Callback báo HomeVC reload table sau khi bookmark thay đổi
    var onBookmarkToggle: (() -> Void)?

    // Reader Mode state
    private var isReaderMode    = false
    private var originalHTML    = ""

    // Nav bar buttons
    private var bookmarkBarBtn:    UIBarButtonItem!
    private var readerBarBtn:      UIBarButtonItem!
    private var reloadBarBtn:      UIBarButtonItem!
    private var pipBarBtn:         UIBarButtonItem!
    private var fullscreenBarBtn:  UIBarButtonItem!

    // Fullscreen state
    private var isFullscreen = false
    private var savedNavBarHidden = false

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

        // ── Nav bar buttons (right side: reload | reader | bookmark)
        reloadBarBtn = UIBarButtonItem(
            image: UIImage(systemName: "arrow.clockwise"),
            style: .plain, target: self, action: #selector(reload))

        readerBarBtn = UIBarButtonItem(
            image: UIImage(systemName: "doc.plaintext"),
            style: .plain, target: self, action: #selector(toggleReaderMode))
        readerBarBtn.tintColor = UIColor.white.withAlphaComponent(0.4)

        let isBookmarked = BookmarkStore.shared.contains(url: url.absoluteString)
        bookmarkBarBtn = UIBarButtonItem(
            image: UIImage(systemName: isBookmarked ? "bookmark.fill" : "bookmark"),
            style: .plain, target: self, action: #selector(toggleBookmark))
        bookmarkBarBtn.tintColor = isBookmarked ? .accentBlue : UIColor.white.withAlphaComponent(0.6)

        // PiP button — chỉ hiện khi vào YouTube/video site
        pipBarBtn = UIBarButtonItem(
            image: UIImage(systemName: "pip.enter"),
            style: .plain, target: self, action: #selector(enterPiP))
        pipBarBtn.tintColor = UIColor.white.withAlphaComponent(0.4)

        // Fullscreen button
        fullscreenBarBtn = UIBarButtonItem(
            image: UIImage(systemName: "arrow.up.left.and.arrow.down.right"),
            style: .plain, target: self, action: #selector(toggleFullscreen))
        fullscreenBarBtn.tintColor = UIColor.white.withAlphaComponent(0.65)

        updateNavButtons()

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

    // YouTube UA — dùng khi vào youtube.com để được serve đầy đủ tính năng
    private var youtubeUserAgent: String {
        "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) " +
        "AppleWebKit/605.1.15 (KHTML, like Gecko) " +
        "Version/17.0 Mobile/15E148 Safari/604.1"
    }
    private var isYouTubeSite: Bool {
        url.host?.contains("youtube.com") == true || url.host?.contains("youtu.be") == true
    }

    private func setupWebView() {
        let cfg = WKWebViewConfiguration()

        // ── Media: inline + PiP
        cfg.allowsInlineMediaPlayback = true
        cfg.mediaTypesRequiringUserActionForPlayback = []
        cfg.allowsAirPlayForMediaPlayback = true

        // ── Persistent session (cookie, đăng nhập không mất)
        cfg.websiteDataStore = WKWebsiteDataStore.default()

        // ── JS luôn bật
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        cfg.defaultWebpagePreferences = prefs
        cfg.selectionGranularity = .character

        let uc = cfg.userContentController

        // ── Viewport fix (iOS 15 reflow)
        uc.addUserScript(WKUserScript(source: """
            (function(){
                var m=document.querySelector('meta[name=viewport]');
                if(!m){m=document.createElement('meta');m.name='viewport';document.head.appendChild(m);}
                m.content='width=device-width,initial-scale=1,maximum-scale=5';
            })();
        """, injectionTime: .atDocumentStart, forMainFrameOnly: true))

        // ── Chặn quảng cáo YouTube: ẩn ad overlay, skip ad button, banner
        uc.addUserScript(WKUserScript(source: """
            (function(){
                var AD_SELECTORS = [
                    '.ad-showing','.ytp-ad-module','.ytp-ad-overlay-container',
                    '.ytp-ad-text-overlay','.ytp-ad-skip-button-container',
                    '#player-ads','ytd-banner-promo-renderer','ytd-ad-slot-renderer',
                    'ytd-promoted-sparkles-web-renderer','.ytd-display-ad-renderer',
                    '#masthead-ad','ytd-statement-banner-renderer',
                    '.ytp-ce-element','#movie_player .ad-interrupting'
                ];
                function removeAds(){
                    AD_SELECTORS.forEach(function(sel){
                        document.querySelectorAll(sel).forEach(function(el){
                            el.style.display='none';
                        });
                    });
                    // Auto-click skip button nếu xuất hiện
                    var skip=document.querySelector('.ytp-skip-ad-button,.ytp-ad-skip-button');
                    if(skip) skip.click();
                    // Nếu video đang trong ad (currentTime < 5), skip
                    var vid=document.querySelector('video');
                    if(vid && document.querySelector('.ad-showing')){
                        vid.currentTime=vid.duration||30;
                    }
                }
                // Chạy ngay + theo dõi DOM thay đổi
                removeAds();
                var obs=new MutationObserver(removeAds);
                obs.observe(document.documentElement,{childList:true,subtree:true});
                setInterval(removeAds,800);
            })();
        """, injectionTime: .atDocumentEnd, forMainFrameOnly: false))

        // ── Picture-in-Picture: khi YouTube fullscreen → bật PiP tự động
        uc.addUserScript(WKUserScript(source: """
            (function(){
                document.addEventListener('fullscreenchange',function(){
                    var vid=document.querySelector('video');
                    if(!document.fullscreenElement && vid){
                        if(vid.readyState>=2 && typeof vid.requestPictureInPicture==='function'){
                            vid.requestPictureInPicture().catch(function(){});
                        }
                    }
                });
            })();
        """, injectionTime: .atDocumentEnd, forMainFrameOnly: false))

        // ── Performance: tắt scroll-behavior CSS mặc định
        uc.addUserScript(WKUserScript(source: """
            document.addEventListener('DOMContentLoaded',function(){
                var s=document.createElement('style');
                s.textContent='*,*::before,*::after{scroll-behavior:auto!important}';
                document.head.appendChild(s);
            });
        """, injectionTime: .atDocumentStart, forMainFrameOnly: false))

        // ── Build WKWebView
        webView = WKWebView(frame: view.bounds, configuration: cfg)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.allowsLinkPreview = true

        // ── Scroll
        webView.scrollView.decelerationRate = .normal
        webView.scrollView.contentInsetAdjustmentBehavior = .automatic
        webView.scrollView.showsHorizontalScrollIndicator = false

        // ── Tránh flash trắng khi load
        webView.isOpaque = false
        webView.backgroundColor = .black
        webView.scrollView.backgroundColor = .black

        // ── User-Agent Safari thật
        webView.customUserAgent = youtubeUserAgent

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
        progressBar.trackTintColor    = .clear
        progressBar.layer.cornerRadius = 1.5
        progressBar.clipsToBounds = true
        progressBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressBar)
        NSLayoutConstraint.activate([
            progressBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            progressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressBar.heightAnchor.constraint(equalToConstant: 3),
        ])
        // Throttle KVO: chỉ update UI khi tiến độ thay đổi >= 2% — tránh redraw liên tục
        var lastReported: Float = 0
        kvoToken = webView.observe(\.estimatedProgress, options: .new) { [weak self] wv, _ in
            let p = Float(wv.estimatedProgress)
            guard abs(p - lastReported) >= 0.02 || p >= 1.0 else { return }
            lastReported = p
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.progressBar.setProgress(p, animated: true)
                if p >= 1.0 {
                    // Delay ẩn để user thấy bar hoàn thành
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        UIView.animate(withDuration: 0.25) { self.progressBar.alpha = 0 }
                        completion: { _ in
                            self.progressBar.isHidden = true
                            self.progressBar.alpha    = 1
                            self.progressBar.setProgress(0, animated: false)
                        }
                    }
                } else {
                    self.progressBar.isHidden = false
                    self.progressBar.alpha    = 1
                }
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

        // Copy Safari → WKWebView
        for cookie in safari {
            g.enter()
            store.setCookie(cookie) { g.leave() }
        }
        // Copy WKWebView → Safari (2 chiều)
        g.enter()
        store.getAllCookies { cookies in
            for c in cookies { HTTPCookieStorage.shared.setCookie(c) }
            g.leave()
        }

        // Timeout 3s: nếu cookie sync treo thì vẫn load trang
        let deadline = DispatchTime.now() + 3.0
        g.notify(queue: .main) { [weak self] in self?.loadPage() }
        DispatchQueue.main.asyncAfter(deadline: deadline) { [weak self] in
            guard let self = self, self.webView.url == nil else { return }
            self.loadPage()  // fallback nếu notify chưa fire
        }
    }

    func persistCookiesToSafari() {
        WKWebsiteDataStore.default().httpCookieStore.getAllCookies { cookies in
            for c in cookies { HTTPCookieStorage.shared.setCookie(c) }
        }
    }

    func loadPage() {
        guard isNetworkAvailable else { showNoNetworkAlert(); return }
        retryCount = 0

        // Cache: dùng cache nếu có, fallback mạng → trang load ngay khi offline/mạng yếu
        var req = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 15)

        // Headers chuẩn Safari → tránh bị chặn hoặc serve trang rút gọn
        req.setValue(webView.customUserAgent, forHTTPHeaderField: "User-Agent")
        req.setValue("text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8", forHTTPHeaderField: "Accept")
        req.setValue("vi-VN,vi;q=0.9,en-US;q=0.8,en;q=0.7", forHTTPHeaderField: "Accept-Language")
        req.setValue("gzip, deflate, br", forHTTPHeaderField: "Accept-Encoding")

        webView.load(req)
    }

    @objc func reload() {
        guard isNetworkAvailable else { showNoNetworkAlert(); return }
        isReaderMode = false
        retryCount = 0; webView.reload()
    }

    func showNoNetworkAlert() {
        let a = UIAlertController(title: "Không có mạng", message: "Kiểm tra Wi-Fi hoặc 4G rồi thử lại.", preferredStyle: .alert)
        a.addAction(UIAlertAction(title: "Thử lại", style: .default) { [weak self] _ in self?.loadPage() })
        a.addAction(UIAlertAction(title: "Huỷ", style: .cancel))
        present(a, animated: true)
    }

    // ✅ Toggle Bookmark
    @objc private func toggleBookmark() {
        let urlStr = url.absoluteString
        if BookmarkStore.shared.contains(url: urlStr) {
            // Xoá — chỉ xoá custom, không xoá built-in
            let all = BookmarkStore.shared.all
            if let bm = all.first(where: { $0.url == urlStr }), !bm.isBuiltIn {
                BookmarkStore.shared.remove(id: bm.id)
                bookmarkBarBtn.image = UIImage(systemName: "bookmark")
                bookmarkBarBtn.tintColor = UIColor.white.withAlphaComponent(0.6)
                onBookmarkToggle?()
            }
        } else {
            // Thêm mới
            let name = webView.title?.trimmingCharacters(in: .whitespaces).nonEmpty ?? (url.host ?? urlStr)
            let bm = Bookmark(name: name, url: urlStr, isBuiltIn: false,
                              iconName: "star.fill", iconColorHex: "#FFD700", iconBgHex: "#FFD70030", badge: nil)
            BookmarkStore.shared.add(bm)
            bookmarkBarBtn.image = UIImage(systemName: "bookmark.fill")
            bookmarkBarBtn.tintColor = .accentBlue
            onBookmarkToggle?()
            // Haptic
            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
    }

    // ✅ Reader Mode — inject CSS + strip nav/ads/sidebar
    @objc private func toggleReaderMode() {
        if isReaderMode {
            // Thoát reader: reload trang gốc
            isReaderMode = false
            readerBarBtn.tintColor = UIColor.white.withAlphaComponent(0.55)
            webView.reload()
        } else {
            // Vào reader: inject JS lấy nội dung chính + CSS thuần
            let js = """
            (function() {
                var article = document.querySelector('article') ||
                              document.querySelector('[role="main"]') ||
                              document.querySelector('.article-body') ||
                              document.querySelector('.post-content') ||
                              document.querySelector('.entry-content') ||
                              document.querySelector('main') ||
                              document.body;
                var content = article ? article.innerHTML : document.body.innerHTML;
                var title   = document.title || '';
                var html = `<!DOCTYPE html><html><head><meta charset='UTF-8'>
                <meta name='viewport' content='width=device-width,initial-scale=1'>
                <style>
                  *{box-sizing:border-box;margin:0;padding:0}
                  body{background:#0f1117;color:#e8e8e8;font-family:-apple-system,sans-serif;
                       font-size:17px;line-height:1.75;padding:20px 18px 60px;max-width:700px;margin:0 auto}
                  h1,h2,h3{color:#fff;margin:1.2em 0 0.5em;line-height:1.3}
                  h1{font-size:1.6em}h2{font-size:1.3em}h3{font-size:1.1em}
                  p{margin:0.8em 0}
                  a{color:#78b4ff;text-decoration:none}
                  img{max-width:100%;border-radius:10px;margin:12px 0}
                  pre,code{background:#1e2230;padding:2px 6px;border-radius:5px;font-size:14px}
                  blockquote{border-left:3px solid #78b4ff;padding-left:14px;color:#aaa;margin:12px 0}
                  .reader-title{font-size:1.7em;font-weight:700;color:#fff;margin-bottom:18px;line-height:1.3}
                  nav,header,footer,aside,.sidebar,.ads,.advertisement,[class*="banner"],[class*="popup"]{display:none!important}
                </style></head><body>
                <div class='reader-title'>${title}</div>
                ${content}
                </body></html>`;
                return html;
            })()
            """
            webView.evaluateJavaScript(js) { [weak self] result, _ in
                guard let self = self, let html = result as? String else { return }
                self.isReaderMode = true
                self.readerBarBtn.tintColor = UIColor.accentBlue
                self.webView.loadHTMLString(html, baseURL: self.url)
            }
        }
    }

    // ── Cập nhật nav buttons tuỳ theo site
    private func updateNavButtons() {
        if isYouTubeSite {
            navigationItem.rightBarButtonItems = [reloadBarBtn, pipBarBtn, fullscreenBarBtn, bookmarkBarBtn]
        } else {
            navigationItem.rightBarButtonItems = [reloadBarBtn, readerBarBtn, bookmarkBarBtn]
        }
    }

    // ── Picture-in-Picture: inject JS yêu cầu video vào PiP
    @objc private func enterPiP() {
        let js = """
        (function(){
            var vid = document.querySelector('video');
            if(vid && typeof vid.requestPictureInPicture === 'function'){
                vid.requestPictureInPicture().catch(function(e){ console.log('PiP error:',e); });
            } else {
                // YouTube: click nút fullscreen để trigger PiP qua fullscreenchange event
                var fsBtn = document.querySelector('.ytp-fullscreen-button');
                if(fsBtn) fsBtn.click();
            }
        })();
        """
        webView.evaluateJavaScript(js, completionHandler: nil)
        pipBarBtn.tintColor = .accentBlue
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    // ── Fullscreen: ẩn nav bar + status bar → web chiếm toàn màn hình
    @objc private func toggleFullscreen() {
        isFullscreen.toggle()
        let hide = isFullscreen
        UIView.animate(withDuration: 0.28) {
            self.navigationController?.setNavigationBarHidden(hide, animated: false)
        }
        setNeedsStatusBarAppearanceUpdate()
        fullscreenBarBtn.image = UIImage(systemName: isFullscreen
            ? "arrow.down.right.and.arrow.up.left"
            : "arrow.up.left.and.arrow.down.right")
        // Double-tap để thoát fullscreen
        if isFullscreen {
            let tap = UITapGestureRecognizer(target: self, action: #selector(exitFullscreenTap))
            tap.numberOfTapsRequired = 2
            tap.name = "exitFS"
            webView.addGestureRecognizer(tap)
        } else {
            webView.gestureRecognizers?.filter { $0.name == "exitFS" }.forEach {
                webView.removeGestureRecognizer($0)
            }
        }
    }

    @objc private func exitFullscreenTap() {
        if isFullscreen { toggleFullscreen() }
    }

    override var prefersStatusBarHidden: Bool { isFullscreen }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation { .slide }
}

// String helper
private extension String {
    var nonEmpty: String? { isEmpty ? nil : self }
}

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        retryCount = 0
        progressBar.isHidden = true; progressBar.setProgress(0, animated: false)
        if let t = webView.title, !t.isEmpty { title = t }
        persistCookiesToSafari()
        readerBarBtn.tintColor = UIColor.white.withAlphaComponent(0.75)
        updateNavButtons()

        // Re-run ad blocker mỗi khi page load xong (YouTube navigate không reload full page)
        if isYouTubeSite {
            pipBarBtn.tintColor = UIColor.white.withAlphaComponent(0.75)
            // Force re-inject ad block sau khi SPA navigate
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                self?.webView.evaluateJavaScript("""
                    (function(){
                        var skip=document.querySelector('.ytp-skip-ad-button,.ytp-ad-skip-button');
                        if(skip) skip.click();
                        var vid=document.querySelector('video');
                        if(vid && document.querySelector('.ad-showing') && vid.duration > 0){
                            vid.currentTime=vid.duration;
                        }
                        ['.ytp-ad-module','.ytp-ad-overlay-container','#player-ads',
                         'ytd-ad-slot-renderer','#masthead-ad'].forEach(function(s){
                            document.querySelectorAll(s).forEach(function(el){el.style.display='none';});
                        });
                    })();
                """, completionHandler: nil)
            }
        }
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
        guard let reqURL = action.request.url else { decisionHandler(.cancel); return }
        let scheme = reqURL.scheme ?? ""
        guard ["https","http","about","blob"].contains(scheme) else { decisionHandler(.cancel); return }

        // Chặn ad network domains ở tầng network (trước khi load)
        let host = reqURL.host ?? ""
        let adHosts: [String] = [
            "doubleclick.net","googlesyndication.com","googleadservices.com",
            "adservice.google.com","pagead2.googlesyndication.com",
            "tpc.googlesyndication.com","ads.youtube.com",
            "static.doubleclick.net","adnxs.com","outbrain.com","taboola.com",
        ]
        if adHosts.contains(where: { host.hasSuffix($0) }) {
            decisionHandler(.cancel); return
        }
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
// MARK: - CustomTabBar  (dark glass pill style)
// ─────────────────────────────────────────
final class CustomTabBar: UIView {

    struct Item {
        let icon: String        // SF Symbol
        let label: String
    }

    private let items: [Item] = [
        Item(icon: "house.fill",   label: "Trang chủ"),
        Item(icon: "clock.fill",   label: "Lịch sử"),
        Item(icon: "gearshape.fill", label: "Cài đặt"),
        Item(icon: "info.circle.fill", label: "Tác giả"),
    ]

    var onSelect: ((Int) -> Void)?
    private(set) var selectedIndex: Int = 0
    private var buttons: [UIButton] = []
    private let pillView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        // Glass background
        backgroundColor = UIColor.white.withAlphaComponent(0.07)
        layer.cornerRadius  = 26
        layer.borderWidth   = 0.5
        layer.borderColor   = UIColor.white.withAlphaComponent(0.12).cgColor

        // Blur underneath
        let blur = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
        blur.frame = bounds
        blur.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blur.layer.cornerRadius = 26
        blur.clipsToBounds = true
        insertSubview(blur, at: 0)

        // Active pill
        pillView.backgroundColor = UIColor.white.withAlphaComponent(0.13)
        pillView.layer.cornerRadius = 20
        addSubview(pillView)

        // Buttons
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])

        for (i, item) in items.enumerated() {
            let btn = UIButton(type: .custom)
            btn.tag = i
            btn.addTarget(self, action: #selector(tabTapped(_:)), for: .touchUpInside)

            // Icon
            let iconIV = UIImageView()
            iconIV.image = UIImage(systemName: item.icon,
                withConfiguration: UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold))
            iconIV.contentMode = .scaleAspectFit
            iconIV.tintColor = (i == 0) ? .white : UIColor.white.withAlphaComponent(0.30)
            iconIV.translatesAutoresizingMaskIntoConstraints = false
            iconIV.tag = 100   // find later by tag

            // Label
            let lbl = UILabel()
            lbl.text = item.label
            lbl.font = .systemFont(ofSize: 10, weight: .medium)
            lbl.textColor = (i == 0) ? .white : UIColor.white.withAlphaComponent(0.30)
            lbl.textAlignment = .center
            lbl.translatesAutoresizingMaskIntoConstraints = false
            lbl.tag = 200

            let col = UIStackView(arrangedSubviews: [iconIV, lbl])
            col.axis = .vertical; col.spacing = 3; col.alignment = .center
            col.isUserInteractionEnabled = false
            col.translatesAutoresizingMaskIntoConstraints = false
            btn.addSubview(col)
            NSLayoutConstraint.activate([
                col.centerXAnchor.constraint(equalTo: btn.centerXAnchor),
                col.centerYAnchor.constraint(equalTo: btn.centerYAnchor),
                iconIV.heightAnchor.constraint(equalToConstant: 22),
            ])

            buttons.append(btn)
            stack.addArrangedSubview(btn)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        movePill(to: selectedIndex, animated: false)
    }

    @objc private func tabTapped(_ sender: UIButton) {
        let i = sender.tag
        guard i != selectedIndex else { return }
        select(index: i, animated: true)
        onSelect?(i)
    }

    func select(index: Int, animated: Bool) {
        _ = selectedIndex
        selectedIndex = index

        // Update colors
        for (i, btn) in buttons.enumerated() {
            let active = (i == index)
            let col = UIColor.white.withAlphaComponent(active ? 1.0 : 0.30)
            if let stack = btn.subviews.compactMap({ $0 as? UIStackView }).first {
                for sub in stack.arrangedSubviews {
                    if let iv = sub as? UIImageView { iv.tintColor = col }
                    if let l  = sub as? UILabel     { l.textColor  = col }
                }
            }
        }

        movePill(to: index, animated: animated)

        // Bounce icon
        if animated, let btn = buttons[safe: index] {
            if let stack = btn.subviews.compactMap({ $0 as? UIStackView }).first,
               let iv = stack.arrangedSubviews.first as? UIImageView {
                UIView.animate(withDuration: 0.12, animations: {
                    iv.transform = CGAffineTransform(scaleX: 1.25, y: 1.25)
                }) { _ in
                    UIView.animate(withDuration: 0.15) { iv.transform = .identity }
                }
            }
        }
    }

    private func movePill(to index: Int, animated: Bool) {
        guard !buttons.isEmpty else { return }
        let btnW = bounds.width / CGFloat(buttons.count)
        let pillW = btnW - 12
        let pillH: CGFloat = 52
        let x = btnW * CGFloat(index) + 6
        let y = (bounds.height - pillH) / 2
        let target = CGRect(x: x, y: y, width: pillW, height: pillH)
        if animated {
            UIView.animate(withDuration: 0.30,
                           delay: 0,
                           usingSpringWithDamping: 0.72,
                           initialSpringVelocity: 0.5) {
                self.pillView.frame = target
            }
        } else {
            pillView.frame = target
        }
    }
}

private extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

// ─────────────────────────────────────────
// MARK: - MainTabBarController
// ─────────────────────────────────────────
final class MainTabBarController: UIViewController {

    private let tabBar    = CustomTabBar()
    private let container = UIView()
    private var vcs: [UIViewController] = []
    private var current: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black

        // Child VCs for each tab
        let homeNav    = UINavigationController(rootViewController: HomeViewController())
        let historyVC  = HistoryViewController()
        let settingsVC = SettingsViewController()
        let aboutNav   = UINavigationController(rootViewController: AboutViewController())
        vcs = [homeNav, historyVC, settingsVC, aboutNav]

        // Container
        container.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(container)

        // Tab bar
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tabBar)

        NSLayoutConstraint.activate([
            // Tab bar: float above bottom, 14pt margin each side
            tabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            tabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),
            tabBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            tabBar.heightAnchor.constraint(equalToConstant: 64),

            // Container fills everything above tab bar
            container.topAnchor.constraint(equalTo: view.topAnchor),
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            container.bottomAnchor.constraint(equalTo: tabBar.topAnchor, constant: -8),
        ])

        tabBar.onSelect = { [weak self] index in
            self?.switchTo(index: index)
        }

        switchTo(index: 0)
    }

    private func switchTo(index: Int) {
        guard let newVC = vcs[safe: index] else { return }

        // Remove current
        if let cur = current {
            cur.willMove(toParent: nil)
            cur.view.removeFromSuperview()
            cur.removeFromParent()
        }

        // Add new
        addChild(newVC)
        newVC.view.frame = container.bounds
        newVC.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        container.addSubview(newVC.view)
        newVC.didMove(toParent: self)
        current = newVC

        // Sync tab bar
        tabBar.select(index: index, animated: true)
    }

    // Expose for AboutViewController to push
    func pushAbout() { switchTo(index: 3) }
}

// ─────────────────────────────────────────
// MARK: - HistoryViewController  (stub)
// ─────────────────────────────────────────
final class HistoryViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red:0.07,green:0.08,blue:0.10,alpha:1)
        let lbl = UILabel()
        lbl.text = "Lịch sử truy cập"
        lbl.font = .systemFont(ofSize: 18, weight: .semibold)
        lbl.textColor = UIColor.white.withAlphaComponent(0.4)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(lbl)
        NSLayoutConstraint.activate([
            lbl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            lbl.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
}

// ─────────────────────────────────────────
// MARK: - SettingsViewController  (stub)
// ─────────────────────────────────────────
final class SettingsViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red:0.07,green:0.08,blue:0.10,alpha:1)
        let lbl = UILabel()
        lbl.text = "Cài đặt"
        lbl.font = .systemFont(ofSize: 18, weight: .semibold)
        lbl.textColor = UIColor.white.withAlphaComponent(0.4)
        lbl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(lbl)
        NSLayoutConstraint.activate([
            lbl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            lbl.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
}

// ─────────────────────────────────────────
// Entry point: dùng MainTabBarController thay vì HomeViewController
typealias ViewController = MainTabBarController
