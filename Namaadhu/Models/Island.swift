import Foundation
import GRDB

struct Island: FetchableRecord, Identifiable, Codable, Equatable, Hashable {
  let id: Int
  let categoryId: Int
  let atoll: Atoll
  let island: String
  let minutes: Int
  let latitude: Double
  let longitude: Double
  let status: Int

  var name: String {
    "\(atoll.rawValue) \(island)"
  }

  private enum CodingKeys: String, CodingKey {
    case id, atoll, island, minutes, latitude, longitude, status
    case categoryId = "category_id"
  }
}

enum Atoll: String, CaseIterable, Codable, Hashable, Identifiable,
  DatabaseValueConvertible
{
  case haaAlifu = "HA."
  case haaDhaalu = "HDh."
  case shaviyani = "Sh."
  case noonu = "N."
  case raa = "R."
  case baa = "B."
  case lhaviyani = "Lh."
  case kaafu = "K."
  case alifuAlifu = "AA."
  case alifuDhaalu = "ADh."
  case vaavu = "V."
  case meemu = "M."
  case faafu = "F."
  case dhaalu = "Dh."
  case thaa = "Th."
  case laamu = "L."
  case gaafuAlifu = "GA."
  case gaafuDhaalu = "GDh."
  case gnaviyani = "Gn."
  case seenu = "S."

  var id: String { rawValue }

  var fullName: String {
    switch self {
    case .haaAlifu: return "Haa Alifu"
    case .haaDhaalu: return "Haa Dhaalu"
    case .shaviyani: return "Shaviyani"
    case .noonu: return "Noonu"
    case .raa: return "Raa"
    case .baa: return "Baa"
    case .lhaviyani: return "Lhaviyani"
    case .kaafu: return "Kaafu"
    case .alifuAlifu: return "Alifu Alifu"
    case .alifuDhaalu: return "Alifu Dhaalu"
    case .vaavu: return "Vaavu"
    case .meemu: return "Meemu"
    case .faafu: return "Faafu"
    case .dhaalu: return "Dhaalu"
    case .thaa: return "Thaa"
    case .laamu: return "Laamu"
    case .gaafuAlifu: return "Gaafu Alifu"
    case .gaafuDhaalu: return "Gaafu Dhaalu"
    case .gnaviyani: return "Gnaviyani"
    case .seenu: return "Seenu"
    }
  }

  var displayOrder: Int {
    Self.allCases.firstIndex(of: self) ?? .max
  }
}
