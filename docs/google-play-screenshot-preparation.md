# Google Play Screenshot Preparation

This document briefly records how I prepared Veilmi screenshots for Google Play
and for the Usage Guide.

## Screenshot Preparation

I captured Veilmi running on a real Android test device in both:

- English
- Traditional Chinese

I prepared seven screenshots for each language, showing the main Veilmi
workflow and application screens.

The screenshots are stored in:

```text
assets/app_screenshots/
```

I cropped unnecessary Android system information, such as the status bar, and
adjusted the image dimensions before using the screenshots.

---

## Checking the Screenshot Dimensions

After editing the screenshots, I checked their file type and dimensions with:

```bash
file assets/app_screenshots/*.jpg
```

I also used this Bash script to check that the screenshots stayed within the
Google Play aspect-ratio limit:

```bash
for f in assets/app_screenshots/*.jpg; do
  dimensions=$(file "$f" | grep -oE '[0-9]+x[0-9]+' | tail -1)
  w=${dimensions%x*}
  h=${dimensions#*x}

  if (( h <= w * 2 )); then
    echo "OK   $f  ${w}x${h}"
  else
    echo "FAIL $f  ${w}x${h}  (max height: $((w * 2)))"
  fi
done
```

The script reads the width and height of each screenshot and checks:

```text
height <= width × 2
```

After the final cropping, all 14 screenshots passed this check.

This gave me a simple way to confirm that the screenshots fit the basic
Google Play screenshot dimension and aspect-ratio requirements before using
them as release assets.

---

## Using the Screenshots in the Documentation

The same screenshots are also used to create a visual Usage Guide for Veilmi.

The guides show the encryption and decryption workflow as well as the main
settings and information screens:

- [Veilmi Usage Guide](usage-guide.md)
- [Veilmi 使用指南](usage-guide.zh.md)

This lets readers understand how Veilmi works even before installing the app.