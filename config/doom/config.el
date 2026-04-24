;;; config.el -*- lexical-binding: t; -*-

(setq confirm-kill-emacs nil)

;; ddskk
(setq default-input-method "japanese-skk")
(setq skk-large-jisyo (expand-file-name "~/.cache/dpp/repos/github.com/skk-dev/dict/SKK-JISYO.L"))
(setq skk-use-azik t)
(setq skk-azik-keyboard-type 'jp)
(setq skk-egg-like-newline t)           ; registerConvertResult equivalent
(setq skk-henkan-point-key ":")         ; : を変換ポイントに
(map! :i "C-j" #'skk-mode)

(after! ddskk
  ;; カスタムかなルール
  (setq skk-rom-kana-rule-list
        (append skk-rom-kana-rule-list
                '(("xx" "x" ("ッ" . "っ"))
                  ("xxa" nil ("ァ" . "ぁ"))
                  ("xxi" nil ("ィ" . "ぃ"))
                  ("xxu" nil ("ゥ" . "ぅ"))
                  ("xxe" nil ("ェ" . "ぇ"))
                  ("xxo" nil ("ォ" . "ぉ"))
                  ("xxya" nil ("ャ" . "ゃ"))
                  ("xxyu" nil ("ュ" . "ゅ"))
                  ("xxyo" nil ("ョ" . "ょ"))
                  ("xxwa" nil ("ヮ" . "ゎ"))
                  ("rr" nil ("レル" . "れる"))
                  ("nn" nil ("ナン" . "なん"))))))
