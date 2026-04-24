import os
from crewai import Agent, Task, Crew, Process

# Modellere bağlan (Araçları kaldırdık çünkü Llama 3 desteklemiyor)
my_llm = "ollama/llama3"

# Dosyayı biz okuyup ajana verelim (En garantisi bu)
with open("main.dart", "r", encoding="utf-8") as f:
    mevcut_kod = f.read()

# AJAN: Senior Dart Developer
yazilimci = Agent(
  role='Senior Dart Developer',
  goal='Mevcut Dart kodlarını AI servisleriyle modernize etmek.',
  backstory='Sen Flutter konusunda uzmansın ve modern AI entegrasyonlarını çok iyi biliyorsun.',
  llm=my_llm,
  verbose=True
)

# GÖREV: Kodu Yeniden Yaz
gorev_guncelle = Task(
  description=f"""
  Aşağıdaki 'main.dart' kodunu oku. 
  Buna AI metin üretme ve görsel oluşturma fonksiyonlarını ekleyerek modernize et.
  Çıktı olarak SADECE güncellenmiş kodun tamamını ver.
  
  MEVCUT KOD:
  {mevcut_kod}
  """,
  agent=yazilimci,
  expected_output="main.dart dosyasının tamamen güncellenmiş ve AI entegreli hali."
)

ekip = Crew(
  agents=[yazilimci],
  tasks=[gorev_guncelle],
  process=Process.sequential
)

print("\n--- ANALİZ VE KOD ÜRETİMİ BAŞLIYOR ---\n")
sonuc = ekip.kickoff()
print("\n########################")
print("## YENİ KODUN BURADA ##")
print(sonuc)