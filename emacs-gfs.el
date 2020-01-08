;;; gfs.el --- Global face scaling library

;; Copyright © 2020 Norman Walsh

;; Author: Norman Walsh <ndw@nwalsh.com>
;; Version: 1.0.0
;; Keywords: faces

;; This file is not part of GNU Emacs.

;; This program is Free Software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
;; or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
;; for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:
;
;; This file provides functions to scale faces. Unlike the functions
;; provided by the text-scale mode in face-remap.el, these functions
;; apply to all of the faces, not just the default face.

;;; Code:

(defvar gfs/magnify-factor 1.2
  "The scaling factor.
Scaling is accomplished by multiplying (or dividing) the face
:height by this factor.")

(defvar gfs/face-min-size 100
  "The minimum face :height.
If an attempt is made to scale the face height below this
threshold, this value will be used.")

(defvar gfs/face-max-size 1000
  "The maximum face :height.
If an attempt is made to scale the face height above this
threshold, this value will be used.")

(defvar gfs/resizeable-ignore-faces
  '(mode-line-buffer-id
    mode-line-emphasis
    mode-line-highlight
    mode-line-inactive
    mode-line)
"Faces named in this list will not be scaled.")

(defun gfs/resizeable-faces ()
  "Return the set of faces that can be resized.
A face can be resized if it is not in the list of ignorable
faces and has an explicit height."
  (let ((faces (face-list))
        (resize '()))
    (while faces
      (if (and (not (member (car faces) gfs/resizeable-ignore-faces))
               (integerp (face-attribute (car faces) :height)))
          (setq resize (append resize (list (car faces)))))
      (setq faces (cdr faces)))
    resize))

(defvar gfs/default-face-height 180
"Default height for faces with no explicit height.")

(defun gfs--/face-height (face)
  (if (integerp (face-attribute face :height))
      (face-attribute face :height)
    (if (facep (face-attribute face :inherit))
        (gfs--/face-height (face-attribute face :inherit))
      gfs/default-face-height)))

(defun gfs--/fix-ignoreable-face-heights ()
  (let ((faces gfs/resizeable-ignore-faces))
    (while faces
      (set-face-attribute (car faces) nil :height
                          (gfs--/face-height (car faces)))
      (setq faces (cdr faces)))))

(defun gfs--/magnify-faces (factor)
  "Magnify all applicable faces by FACTOR.
If FACTOR is negative, shrink the faces."
  (let ((faces (gfs/resizeable-faces))
        height)
    (gfs--/fix-ignoreable-face-heights)
    (while faces
      (message (symbol-name (car faces)))
      (setq cursize (face-attribute (car faces) :height))
      (setq height 
            (if (> factor 0)
                (floor (* cursize gfs/magnify-factor))
              (floor (/ cursize (abs gfs/magnify-factor)))))
      (if (and (>= height gfs/face-min-size)
               (<= height gfs/face-max-size))
          (set-face-attribute (car faces) nil :height height))
      (setq faces (cdr faces)))))

(defun gfs/shrink-faces ()
  "Shrink all applicable faces by the magnification factor."
  (interactive)
  (gfs--/magnify-faces (- gfs/magnify-factor)))

(defun gfs/magnify-faces ()
  "Magnify all applicable faces by the magnification factor."
  (interactive)
  (gfs--/magnify-faces gfs/magnify-factor))

(provide 'emacs-gfs)

;;; emacs-gfs ends here
