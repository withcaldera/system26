import Foundation

public enum Localization {
  public static let bundle: Bundle = .module

  public enum Language: String, CaseIterable, Identifiable, Sendable {
    case english = "en"
    case chineseSimplified = "zh-Hans"
    case spanish = "es"
    case french = "fr"
    case portuguese = "pt"
    case german = "de"
    case italian = "it"
    case japanese = "ja"
    case korean = "ko"
    case vietnamese = "vi"

    public var id: String { rawValue }

    public var displayName: String {
      switch self {
      case .english:
        return "English"

      case .chineseSimplified:
        return "简体中文"

      case .spanish:
        return "Español"

      case .french:
        return "Français"

      case .portuguese:
        return "Português"

      case .german:
        return "Deutsch"

      case .italian:
        return "Italiano"

      case .japanese:
        return "日本語"

      case .korean:
        return "한국어"

      case .vietnamese:
        return "Tiếng Việt"
      }
    }
  }

  public struct SampleText: Sendable {
    public let language: Language
    public let text: String

    public init(language: Language, text: String) {
      self.language = language
      self.text = text
    }
  }

  public static let generalPrompts: [SampleText] = [
    SampleText(language: .english, text: "Write a short story about a robot learning to paint."),
    SampleText(language: .chineseSimplified, text: "写一个关于机器人学习绘画的短篇故事。"),
    SampleText(
      language: .spanish, text: "Escribe un cuento corto sobre un robot aprendiendo a pintar."),
    SampleText(
      language: .french, text: "Écrivez une courte histoire sur un robot apprenant à peindre."),
    SampleText(language: .portuguese, text: "Escreva um conto sobre um robô aprendendo a pintar."),
    SampleText(
      language: .german, text: "Schreibe eine Kurzgeschichte über einen Roboter, der malen lernt."),
    SampleText(
      language: .italian, text: "Scrivi una breve storia su un robot che impara a dipingere."),
    SampleText(language: .japanese, text: "絵を描くことを学ぶロボットについての短編小説を書いてください。"),
    SampleText(language: .korean, text: "그림 그리는 법을 배우는 로봇에 대한 짧은 이야기를 써보세요."),
    SampleText(language: .vietnamese, text: "Viết một câu chuyện ngắn về một robot đang học vẽ.")
  ]

  public static var currentLanguage: Language {
    if let languages = UserDefaults.standard.stringArray(forKey: "AppleLanguages"),
      let preferred = languages.first {
      for lang in Language.allCases where preferred.hasPrefix(lang.rawValue) {
        return lang
      }
    }

    let locale = Locale.current.identifier
    for lang in Language.allCases where locale.hasPrefix(lang.rawValue) {
      return lang
    }
    return .english
  }

  public static var defaultSystemPrompt: String {
    switch currentLanguage {
    case .english:
      return "You are a helpful scientific assistant."

    case .chineseSimplified:
      return "你是一个乐于助人的科学助手。"

    case .spanish:
      return "Eres un asistente científico útil."

    case .french:
      return "Vous êtes un assistant scientifique utile."

    case .portuguese:
      return "Você é um assistente científico útil."

    case .german:
      return "Du bist ein hilfreicher wissenschaftlicher Assistent."

    case .italian:
      return "Sei un utile assistente scientifico."

    case .japanese:
      return "あなたは役に立つ科学アシスタントです。"

    case .korean:
      return "당신은 도움이 되는 과학 조수입니다."

    case .vietnamese:
      return "Bạn là một trợ lý khoa học hữu ích."
    }
  }

  public static func string(_ key: String) -> String {
    String(localized: String.LocalizationValue(key), bundle: bundle)
  }
}
