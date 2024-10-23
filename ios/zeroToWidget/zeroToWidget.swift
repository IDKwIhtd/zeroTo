import WidgetKit
import SwiftUI

// 서버에서 받아올 데이터를 위한 구조체
struct APIResponse: Codable {
    let data: DataClass
}

struct DataClass: Codable {
    let results: [String: String] // JSON의 results 키-값 쌍을 받는 구조체
}

// Result 구조체: 서버에서 가져온 데이터를 담을 구조체
struct Result: Identifiable {
    let id = UUID() // ForEach에 사용하기 위한 고유 ID
    let key: String
    let value: String
}

struct SimpleEntry: TimelineEntry {
    let timeZone: TimeZone
    let date: Date
    let results: [Result] // 서버에서 가져온 결과 배열
}

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
      SimpleEntry(timeZone: TimeZone.current,date: Date(), results: [Result(key: "Loading", value: "Please wait...")])
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
      let entry = SimpleEntry(timeZone: TimeZone.current, date: Date(), results: [Result(key: "Snapshot", value: "Loading...")])
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        Task {
            let timeZone = TimeZone.current
            let currentDate = Date()
            let results = await fetchResultsFromServer()

            var entries: [SimpleEntry] = []
            
            // 5시간 동안 15분 간격으로 엔트리 생성
            for minuteOffset in stride(from: 0, to: 5 * 60, by: 15) {
                let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: currentDate)!
              let entry = SimpleEntry(timeZone:timeZone, date: entryDate, results: results)
                entries.append(entry)
            }

            // 타임라인 설정, 5시간 후에 다시 갱신
            let nextUpdate = Calendar.current.date(byAdding: .hour, value: 5, to: currentDate)!
            let timeline = Timeline(entries: entries, policy: .after(nextUpdate))
            completion(timeline)
        }
    }

    // 서버에서 데이터를 비동기로 가져오는 함수
    func fetchResultsFromServer() async -> [Result] {
        guard let url = URL(string: "http://localhost:8000/get_results/") else {
            return [Result(key: "Error", value: "Invalid URL")]
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decodedData = try JSONDecoder().decode(APIResponse.self, from: data)
            
            let sortedResults = decodedData.data.results.sorted { $0.key < $1.key }
          let topicsArray = sortedResults.map{ Result(key: $0.key, value: $0.value) }
          return topicsArray
                
            
        } catch {
            return [Result(key: "Error", value: "Failed to load data")]
        }
    }
}

struct zeroToWidgetEntryView: View {
    var entry: Provider.Entry
  
  func formattedDate(date: Date) -> String {
         let formatter = DateFormatter()
         formatter.dateFormat = " yyyy-MM-dd E HH:mm" // 요일, 날짜, 시간 형식
         return formatter.string(from: date)
     }

    var body: some View {
      
     
      
      VStack {
          
        Text(entry.timeZone.identifier).lineSpacing(1).padding(.bottom)
        Text(formattedDate(date: entry.date)).fontWeight(.bold)
              
      
      .font(.system(size: 11))
        .lineSpacing(15)
        .padding(.bottom)
        .containerBackground(.fill, for: .widget);
      
        
            ForEach(entry.results) { result in
                HStack {
                    Text(result.key + ":")
                    Text(result.value)
                }
            }.font(.system(size: 15))
            .italic()
            .containerBackground(.fill, for: .widget);
            
        }
      
        
      
        
    }
}

struct zeroToWidget: Widget {
    let kind: String = "zeroToWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            zeroToWidgetEntryView(entry: entry)
        }
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        .configurationDisplayName("Local Time & Server Data Widget")
        .description("Displays local time and server key-value pairs.")
    }
}









struct zeroToWidget_Previews: PreviewProvider {
    static var previews: some View {
      zeroToWidgetEntryView(entry: SimpleEntry(timeZone:TimeZone.current, date: Date(), results: [Result(key: "PreviewKey", value: "PreviewValue")]))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
