#!/usr/bin/env ruby
# frozen_string_literal: true

# Builds a review page from DECISIONS.md so the owner can clear nomenclature
# rows in one sitting. Output stays under l10n/.work (gitignored).
#
# Usage: ruby scripts/l10n-decisions-report.rb [locale]

require "cgi"
require "json"

locale = ARGV[0] || "tr"
root = File.expand_path("..", __dir__)
ledger_path = File.join(root, "l10n", locale, "DECISIONS.md")
out_path = File.join(root, "l10n", ".work", locale, "decision-review.html")
abort "missing #{ledger_path}" unless File.file?(ledger_path)

rows = []
section = "Genel"
File.readlines(ledger_path, encoding: "UTF-8").each do |line|
  if (match = line.match(/\A## (.+)\s*\z/))
    section = match[1]
  elsif line.start_with?("| D")
    cells = line.split("|").map(&:strip)
    next if cells[1] == "ID"

    rows << {
      "id" => cells[1],
      "term" => cells[2],
      "proposal" => cells[3],
      "alternatives" => cells[4],
      "note" => cells[5],
      "status" => cells[6] || "open",
      "section" => section
    }
  end
end

rows.reject! { |row| row["id"].nil? || row["id"].empty? }
counts = rows.group_by { |row| row["status"] }.transform_values(&:length)
sections = rows.map { |row| row["section"] }.uniq

def esc(value)
  CGI.escapeHTML(value.to_s)
end

data = rows.to_json
page = <<~HTML
  <!doctype html>
  <html lang="tr">
  <head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Türkçe nomenklatür incelemesi</title>
  <style>
    :root {
      --ink: #1c1917;
      --muted: #78716c;
      --line: #e7e5e4;
      --paper: #faf9f7;
      --card: #ffffff;
      --accent: #0f766e;
      --accent-soft: #ccfbf1;
      --open: #b45309;
      --open-soft: #fef3c7;
      --ok: #15803d;
      --ok-soft: #dcfce7;
      --no: #b91c1c;
      --no-soft: #fee2e2;
      --radius: 10px;
    }
    @media (prefers-color-scheme: dark) {
      :root {
        --ink: #f5f5f4;
        --muted: #a8a29e;
        --line: #292524;
        --paper: #12100f;
        --card: #1c1917;
        --accent: #2dd4bf;
        --accent-soft: #134e4a;
        --open: #fbbf24;
        --open-soft: #422006;
        --ok: #4ade80;
        --ok-soft: #052e16;
        --no: #f87171;
        --no-soft: #450a0a;
      }
    }
    * { box-sizing: border-box; }
    body {
      margin: 0;
      background: var(--paper);
      color: var(--ink);
      font: 15px/1.45 -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
    }
    header {
      padding: 40px 32px 24px;
      max-width: 1180px;
      margin: 0 auto;
    }
    h1 {
      margin: 0 0 6px;
      font-size: clamp(24px, 3vw, 32px);
      letter-spacing: -0.02em;
    }
    .lede { color: var(--muted); max-width: 64ch; margin: 0; }
    .stats {
      display: flex;
      flex-wrap: wrap;
      gap: 10px;
      margin-top: 22px;
    }
    .stat {
      background: var(--card);
      border: 1px solid var(--line);
      border-radius: var(--radius);
      padding: 10px 14px;
      min-width: 118px;
    }
    .stat b { display: block; font-size: 20px; letter-spacing: -0.01em; }
    .stat span { color: var(--muted); font-size: 12px; }
    .toolbar {
      position: sticky;
      top: 0;
      z-index: 5;
      background: color-mix(in srgb, var(--paper) 92%, transparent);
      backdrop-filter: blur(8px);
      border-bottom: 1px solid var(--line);
    }
    .toolbar-inner {
      max-width: 1180px;
      margin: 0 auto;
      padding: 12px 32px;
      display: flex;
      gap: 10px;
      flex-wrap: wrap;
      align-items: center;
    }
    input[type="search"] {
      flex: 1 1 240px;
      min-width: 200px;
      padding: 9px 12px;
      border: 1px solid var(--line);
      border-radius: 8px;
      background: var(--card);
      color: var(--ink);
      font: inherit;
    }
    .chip {
      padding: 7px 11px;
      border: 1px solid var(--line);
      border-radius: 999px;
      background: var(--card);
      color: var(--ink);
      font: inherit;
      font-size: 13px;
      cursor: pointer;
    }
    .chip[aria-pressed="true"] { background: var(--accent-soft); border-color: var(--accent); }
    .chip b { font-variant-numeric: tabular-nums; }
    .copy {
      padding: 7px 12px;
      border: 0;
      border-radius: 8px;
      background: var(--accent);
      color: var(--paper);
      font: inherit;
      font-size: 13px;
      cursor: pointer;
    }
    main { max-width: 1180px; margin: 0 auto; padding: 8px 32px 60px; }
    section { margin-top: 34px; }
    h2 {
      font-size: 13px;
      text-transform: uppercase;
      letter-spacing: 0.08em;
      color: var(--muted);
      margin: 0 0 10px;
      display: flex;
      justify-content: space-between;
    }
    h2 b { color: var(--ink); font-variant-numeric: tabular-nums; }
    .table-wrap {
      background: var(--card);
      border: 1px solid var(--line);
      border-radius: var(--radius);
      overflow: hidden;
    }
    table { width: 100%; border-collapse: collapse; }
    th, td { text-align: left; padding: 10px 12px; vertical-align: top; }
    th {
      font-size: 11px;
      letter-spacing: 0.07em;
      text-transform: uppercase;
      color: var(--muted);
      border-bottom: 1px solid var(--line);
      font-weight: 600;
      white-space: nowrap;
    }
    tbody tr { border-bottom: 1px solid var(--line); }
    tbody tr:last-child { border-bottom: 0; }
    tbody tr:hover { background: color-mix(in srgb, var(--accent-soft) 35%, transparent); }
    td.id { font-variant-numeric: tabular-nums; color: var(--muted); white-space: nowrap; font-size: 12px; }
    td.term { font-weight: 600; }
    td.proposal { font-weight: 600; color: var(--accent); }
    td.alt, td.note { color: var(--muted); font-size: 13px; }
    .status {
      display: inline-block;
      padding: 2px 8px;
      border-radius: 999px;
      font-size: 11px;
      font-weight: 600;
      white-space: nowrap;
    }
    .status.open { background: var(--open-soft); color: var(--open); }
    .status.approved { background: var(--ok-soft); color: var(--ok); }
    .status.rejected { background: var(--no-soft); color: var(--no); }
    .empty { padding: 40px; text-align: center; color: var(--muted); }
    footer { max-width: 1180px; margin: 0 auto; padding: 0 32px 50px; color: var(--muted); font-size: 13px; }
    code { background: var(--accent-soft); padding: 1px 5px; border-radius: 4px; }
    @media (max-width: 720px) {
      header, .toolbar-inner, main, footer { padding-left: 16px; padding-right: 16px; }
      th:nth-child(4), td.alt { display: none; }
    }
  </style>
  </head>
  <body>
  <header>
    <h1>Türkçe nomenklatür incelemesi</h1>
    <p class="lede">İlk geçiş tamamlandı: 3.208 kayıt adı Türkçeleştirildi. Aşağıdaki satırlar insan onayı bekleyen terimler; bir satırı onaylamak öneriyi kalıcılaştırır, reddetmek alternatifi seçer.</p>
    <div class="stats">
      <div class="stat"><b>2.015</b><span>Player Core adı</span></div>
      <div class="stat"><b>1.193</b><span>Player Core 2 adı</span></div>
      <div class="stat"><b>#{rows.length}</b><span>karar satırı</span></div>
      <div class="stat"><b>#{counts.fetch("open", 0)}</b><span>açık</span></div>
    </div>
  </header>
  <div class="toolbar">
    <div class="toolbar-inner">
      <input id="q" type="search" placeholder="Terim, öneri ya da D100 ara…" aria-label="Ara">
      <button class="chip" data-status="all" aria-pressed="true">Tümü <b>#{rows.length}</b></button>
      <button class="chip" data-status="open" aria-pressed="false">Açık <b>#{counts.fetch("open", 0)}</b></button>
      <button class="chip" data-status="approved" aria-pressed="false">Onaylı <b>#{counts.fetch("approved", 0)}</b></button>
      <button class="chip" data-status="rejected" aria-pressed="false">Red <b>#{counts.fetch("rejected", 0)}</b></button>
      <button class="copy" id="copy">Görünenleri kopyala</button>
    </div>
  </div>
  <main id="main"></main>
  <footer>
    Cevap biçimi: <code>D101–D140 onay</code>, <code>D141 red: alternatif</code>, <code>D150–D160 açık kalsın</code>.
    Sayfa <code>DECISIONS.md</code> dosyasından üretilir; yeniden üretmek için
    <code>ruby scripts/l10n-decisions-report.rb</code>.
  </footer>
  <script>
    const rows = #{data};
    const sections = #{sections.to_json};
    const statuses = {open: "açık", approved: "onaylı", rejected: "red"};
    const main = document.getElementById("main");
    const q = document.getElementById("q");
    const chips = [...document.querySelectorAll(".chip")];
    let filter = "all";
    let query = "";

    const esc = (s) => String(s).replace(/[&<>"']/g, (c) => ({"&":"&amp;","<":"&lt;",">":"&gt;","\\"":"&quot;","'":"&#39;"}[c]));
    const visible = () => rows.filter((r) => {
      const okStatus = filter === "all" || r.status === filter;
      const hay = (r.id + " " + r.term + " " + r.proposal + " " + r.alternatives + " " + r.section).toLocaleLowerCase("tr");
      return okStatus && (!query || hay.includes(query));
    });

    function render() {
      const list = visible();
      if (!list.length) {
        main.innerHTML = '<div class="empty">Eşleşen satır yok.</div>';
        return;
      }
      main.innerHTML = sections.map((section) => {
        const items = list.filter((r) => r.section === section);
        if (!items.length) return "";
        return '<section><h2>' + esc(section) + '<b>' + items.length + '</b></h2><div class="table-wrap"><table><thead><tr>'
          + '<th>ID</th><th>Terim</th><th>Öneri</th><th>Alternatifler</th><th>Gerekçe / kaynak</th><th>Durum</th>'
          + '</tr></thead><tbody>'
          + items.map((r) => '<tr>'
            + '<td class="id">' + esc(r.id) + '</td>'
            + '<td class="term">' + esc(r.term) + '</td>'
            + '<td class="proposal">' + esc(r.proposal) + '</td>'
            + '<td class="alt">' + esc(r.alternatives) + '</td>'
            + '<td class="alt note">' + esc(r.note) + '</td>'
            + '<td><span class="status ' + esc(r.status) + '">' + esc(statuses[r.status] || r.status) + '</span></td>'
            + '</tr>').join("")
          + '</tbody></table></div></section>';
      }).join("");
    }

    q.addEventListener("input", () => { query = q.value.trim().toLocaleLowerCase("tr"); render(); });
    chips.forEach((chip) => chip.addEventListener("click", () => {
      filter = chip.dataset.status;
      chips.forEach((c) => c.setAttribute("aria-pressed", String(c === chip)));
      render();
    }));
    document.getElementById("copy").addEventListener("click", async () => {
      const text = visible().map((r) => r.id + "\\t" + r.term + "\\t" + r.proposal).join("\\n");
      try { await navigator.clipboard.writeText(text); } catch (e) {}
      const button = document.getElementById("copy");
      const old = button.textContent;
      button.textContent = "Kopyalandı";
      setTimeout(() => { button.textContent = old; }, 1200);
    });
    render();
  </script>
  </body>
  </html>
HTML

File.write(out_path, page, encoding: "UTF-8")
puts "wrote #{out_path} (#{rows.length} rows)"
