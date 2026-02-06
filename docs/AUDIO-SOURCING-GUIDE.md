# Tre Voci — Audio Sourcing & Processing Guide

## Quick Start: Get All 36 Songs

Since this is for personal MVP use and you're OK using copyrighted material for Chinese initially, here's the fastest path to having all 36 audio files ready.

---

## Step 1: Install Tools

```bash
# macOS
brew install yt-dlp ffmpeg
pip3 install ffmpeg-normalize
```

---

## Step 2: Create URL Lists

Create three files with YouTube URLs for each language. Search these channels for the specific songs:

### Best YouTube Channels by Language

| Language | Channel | Why |
|----------|---------|-----|
| 🇮🇹 Italian | **Coccole Sonore** (`youtube.com/user/CoccoleSonore`) | Gold standard Italian nursery rhymes. Has every Italian song on our list. Clean audio, simple arrangements. |
| 🇮🇹 Italian | **HeyKids Italiano** | Good backup, slightly more produced |
| 🇨🇳 Chinese | **BabyBus 宝宝巴士** (`youtube.com/@babybusChinese`) | Has every Chinese song. Episodes numbered — see list below. |
| 🇨🇳 Chinese | **贝瓦儿歌** (BeiWa) | Alternative with traditional arrangements |
| 🇬🇧 English | **Super Simple Songs** (`youtube.com/@SuperSimpleSongs`) | Clean, slow, clear pronunciation. Perfect for toddlers. |
| 🇬🇧 English | **CoComelon** | More produced but very popular versions |

### Specific Song → Search Terms

Use these exact search terms on YouTube to find the right videos:

**Cross-Cultural (search in each language):**

| Song ID | Search: Italian | Search: Chinese | Search: English |
|---------|----------------|-----------------|-----------------|
| frere-jacques | `"Fra Martino Campanaro" coccole sonore` | `"两只老虎" 宝宝巴士` or BabyBus Ep 90 | `"Are You Sleeping Brother John" super simple` |
| twinkle | `"Brilla Brilla la Stellina" coccole sonore` | `"小星星" 宝宝巴士` or BabyBus Ep 97 | `"Twinkle Twinkle Little Star" super simple` |
| old-macdonald | `"Nella Vecchia Fattoria" coccole sonore` | `"王老先生有块地" 宝宝巴士` or BabyBus 3D Ep 16 | `"Old MacDonald Had a Farm" super simple` |
| if-youre-happy | `"Se Sei Felice tu lo sai" coccole sonore` | `"如果感到幸福你就拍拍手" 宝宝巴士` or Ep 95 | `"If You're Happy and You Know It" super simple` |
| head-shoulders | `"Testa Spalle Ginocchia e Piedi" coccole sonore` | `"头肩膀膝脚趾" 宝宝巴士` | `"Head Shoulders Knees and Toes" super simple` |
| happy-birthday | `"Tanti Auguri a Te" bambini` | `"祝你生日快乐" 宝宝巴士` or Ep 100 | `"Happy Birthday" cocomelon` |
| row-your-boat | `"Rema Rema Rema" coccole sonore` | `"划船歌" 儿歌` or `"Row Row Row" 宝宝巴士` | `"Row Row Row Your Boat" super simple` |
| abc-song | `"Canzone dell'Alfabeto ABC" coccole sonore` | `"字母歌 ABC" 宝宝巴士` or Ep 93 | `"ABC Song" super simple` |

**Italian Only:**

| Song ID | Search Term |
|---------|-------------|
| stella-stellina | `"Stella Stellina" coccole sonore` |
| batti-batti | `"Batti Batti le Manine" filastrocca bambini` |
| giro-giro-tondo | `"Giro Giro Tondo" coccole sonore` |
| la-bella-lavanderina | `"La Bella Lavanderina" coccole sonore` |

**Chinese Only:**

| Song ID | Search Term |
|---------|-------------|
| xiao-tuzi-guaiguai | `"小兔子乖乖" 宝宝巴士` or BabyBus Ep 91 |
| ba-luobo | `"拔萝卜" 宝宝巴士` or BabyBus Ep 89 |
| zhao-pengyou | `"找朋友" 宝宝巴士` or BabyBus 3D Ep 14 |
| da-xiang | `"大象" 儿歌 宝宝巴士` |

**English Only:**

| Song ID | Search Term |
|---------|-------------|
| humpty-dumpty | `"Humpty Dumpty" super simple songs` |
| baa-baa-black-sheep | `"Baa Baa Black Sheep" super simple songs` |
| mary-little-lamb | `"Mary Had a Little Lamb" super simple songs` |
| itsy-bitsy-spider | `"Itsy Bitsy Spider" super simple songs` |

---

## Step 3: Download Audio

Once you have the YouTube URLs, create `urls-it.txt`, `urls-zh.txt`, `urls-en.txt` with one URL per line.

```bash
mkdir -p raw/{italian,chinese,english}

# Download Italian
yt-dlp -f "bestaudio[ext=m4a]/bestaudio/best" \
  -x --audio-format m4a --audio-quality 0 \
  -o "raw/italian/%(title)s.%(ext)s" \
  --restrict-filenames --no-overwrites \
  --batch-file urls-it.txt

# Download Chinese
yt-dlp -f "bestaudio[ext=m4a]/bestaudio/best" \
  -x --audio-format m4a --audio-quality 0 \
  -o "raw/chinese/%(title)s.%(ext)s" \
  --restrict-filenames --no-overwrites \
  --batch-file urls-zh.txt

# Download English
yt-dlp -f "bestaudio[ext=m4a]/bestaudio/best" \
  -x --audio-format m4a --audio-quality 0 \
  -o "raw/english/%(title)s.%(ext)s" \
  --restrict-filenames --no-overwrites \
  --batch-file urls-en.txt
```

### Single Video Download (when you know the exact URL)

```bash
yt-dlp -f "bestaudio[ext=m4a]/bestaudio/best" \
  -x --audio-format m4a --audio-quality 0 \
  -o "raw/italian/fra-martino.m4a" \
  "https://www.youtube.com/watch?v=XXXXX"
```

---

## Step 4: Trim (Remove Intros, Outros, Silence)

Many YouTube nursery rhyme videos have spoken intros, channel jingles, or long silences. You'll need to manually note the start/end timestamps for the actual song portion.

### Listen and Note Timestamps

```bash
# Quick preview a file (plays first 30 seconds)
ffplay -autoexit -t 30 raw/italian/fra-martino.m4a
```

### Trim to Specific Timestamps

```bash
# Trim to song portion only (example: song starts at 0:05, ends at 2:20)
ffmpeg -i raw/italian/fra-martino.m4a \
  -ss 00:00:05 -to 00:02:20 \
  -c:a aac -b:a 192k -ar 44100 \
  trimmed/fra-martino-it.m4a
```

### Auto-Trim Silence (start and end only)

```bash
ffmpeg -i input.m4a -af \
  "silenceremove=start_periods=1:start_threshold=-50dB:start_silence=0.2,\
  areverse,\
  silenceremove=start_periods=1:start_threshold=-50dB:start_silence=0.2,\
  areverse" \
  -c:a aac -b:a 192k -ar 44100 trimmed/output.m4a
```

---

## Step 5: Normalize & Finalize

### One-Command Processing (automated two-pass normalization)

```bash
mkdir -p final

# Normalize all trimmed files to -16 LUFS
ffmpeg-normalize trimmed/*.m4a \
  -t -16 -lrt 7 -tp -2 \
  -c:a aac -b:a 192k -ar 44100 \
  -ofmt m4a -of normalized/ -f

# Add fade in/out to all normalized files
for f in normalized/*.m4a; do
  name=$(basename "$f")
  DUR=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$f")
  FO=$(echo "$DUR - 0.3" | bc)
  ffmpeg -y -i "$f" \
    -af "afade=t=in:st=0:d=0.3,afade=t=out:st=${FO}:d=0.3" \
    -c:a aac -b:a 192k -ar 44100 \
    "final/$name" 2>/dev/null
  echo "✓ $name"
done
```

---

## Step 6: Rename to App Convention

The app expects these exact filenames:

```bash
# Cross-cultural (in Resources/Audio/cross-cultural/)
frere-jacques-it.m4a    frere-jacques-zh.m4a    frere-jacques-en.m4a
twinkle-it.m4a          twinkle-zh.m4a          twinkle-en.m4a
old-macdonald-it.m4a    old-macdonald-zh.m4a    old-macdonald-en.m4a
if-youre-happy-it.m4a   if-youre-happy-zh.m4a   if-youre-happy-en.m4a
head-shoulders-it.m4a   head-shoulders-zh.m4a   head-shoulders-en.m4a
happy-birthday-it.m4a   happy-birthday-zh.m4a   happy-birthday-en.m4a
row-your-boat-it.m4a    row-your-boat-zh.m4a    row-your-boat-en.m4a
abc-song-it.m4a         abc-song-zh.m4a         abc-song-en.m4a

# Italian only (in Resources/Audio/italian/)
stella-stellina.m4a
batti-batti.m4a
giro-giro-tondo.m4a
la-bella-lavanderina.m4a

# Chinese only (in Resources/Audio/chinese/)
xiao-tuzi-guaiguai.m4a
ba-luobo.m4a
zhao-pengyou.m4a
da-xiang.m4a

# English only (in Resources/Audio/english/)
humpty-dumpty.m4a
baa-baa-black-sheep.m4a
mary-little-lamb.m4a
itsy-bitsy-spider.m4a
```

Rename your processed files to match, then copy into the Xcode project's `Resources/Audio/` directories.

---

## Step 7: Verify

```bash
# Check all files exist
echo "=== Cross-Cultural ===" && ls final/cross-cultural/ | wc -l  # expect 24
echo "=== Italian ===" && ls final/italian/ | wc -l                 # expect 4
echo "=== Chinese ===" && ls final/chinese/ | wc -l                 # expect 4
echo "=== English ===" && ls final/english/ | wc -l                 # expect 4

# Check loudness of each file
for f in final/**/*.m4a; do
  LUFS=$(ffmpeg -i "$f" -af loudnorm=print_format=summary -f null - 2>&1 | grep "Input Integrated" | awk '{print $4}')
  echo "$(basename $f): ${LUFS} LUFS"
done
# All should be close to -16.0 LUFS

# Check durations
for f in final/**/*.m4a; do
  DUR=$(ffprobe -v error -show_entries format=duration -of csv=p=0 "$f")
  printf "%-40s %s sec\n" "$(basename $f)" "$DUR"
done
```

---

## Audio Specs Summary

| Property | Target | Why |
|----------|--------|-----|
| Format | AAC (.m4a) | Native iOS, AirPlay compatible |
| Bitrate | 192 kbps | Transparent for music |
| Sample Rate | 44,100 Hz | CD quality, universal |
| Loudness | -16 LUFS | Safe for children, Apple Music standard |
| LRA | ≤ 7 LU | No sudden volume jumps (toddler-safe) |
| True Peak | -2 dBTP | Headroom for AAC encoding |
| Fade In/Out | 0.3 sec | Smooth transitions |

---

## Copyright Status Quick Reference

| Song | Melody PD? | Notes |
|------|-----------|-------|
| Frère Jacques / Fra Martino / 两只老虎 | ✅ ~1780 | All 3 versions traditional |
| Twinkle / Brilla Brilla / 小星星 | ✅ 1761 | Same melody as ABC + Baa Baa |
| Old MacDonald / Nella Vecchia Fattoria / 王老先生 | ⚠️ 1706 | Italian 1949 arrangement possibly © |
| If You're Happy / Se Sei Felice / 如果感到幸福 | ⚠️ ~1950s | Specific arrangement may be © |
| Head Shoulders / Testa Spalle / 头肩膀 | ✅ 1912 | Traditional |
| Happy Birthday / Tanti Auguri / 祝你生日快乐 | ✅ 1893 | Ruled PD 2015 |
| Row Your Boat / Rema Rema / 划船歌 | ✅ 1852 | Traditional |
| ABC Song / Canzone Alfabeto / ABC字母歌 | ✅ 1835 | Same melody as Twinkle |
| Stella Stellina | ✅ | Ancient oral tradition |
| Batti Batti le Manine | ✅ | Traditional clapping song |
| Giro Giro Tondo | ✅ | Italian folk |
| La Bella Lavanderina | ✅ | Italian folk |
| 小兔子乖乖 | ✅ | Traditional folk |
| 拔萝卜 | ⚠️ | Lyrics possibly 1950s composition |
| 找朋友 | ✅ | Traditional counting song |
| 大象 | ✅ | Traditional folk |
| Humpty Dumpty | ✅ 1797 | Traditional |
| Baa Baa Black Sheep | ✅ 1744 | Traditional |
| Mary Had a Little Lamb | ✅ 1830 | Traditional |
| Itsy Bitsy Spider | ✅ ~1910 | Traditional |

**⚠️ = OK for personal MVP, verify before commercial distribution.**

**Remember:** Melodies being public domain does NOT make recordings free. Every YouTube download is a copyrighted recording. For personal use / MVP testing this is fine. For App Store release, either license the recordings or commission original ones.
