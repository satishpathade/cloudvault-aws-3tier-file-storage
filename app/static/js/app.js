// Features: Drag & Drop, File Preview, Upload Progress

document.addEventListener('DOMContentLoaded', () => {

    // DRAG & DROP 
    const dropZone = document.getElementById('dropZone');
    const fileInput = document.getElementById('fileInput');
    const uploadForm = document.getElementById('uploadForm');

    if (dropZone) {

        // Drag events
        ['dragenter', 'dragover'].forEach(e => {
            dropZone.addEventListener(e, (ev) => {
                ev.preventDefault();
                dropZone.classList.add('drag-over');
            });
        });

        ['dragleave', 'drop'].forEach(e => {
            dropZone.addEventListener(e, (ev) => {
                ev.preventDefault();
                dropZone.classList.remove('drag-over');
            });
        });

        // Handle drop
        dropZone.addEventListener('drop', (e) => {
            e.preventDefault();
            const files = e.dataTransfer.files;
            if (files.length) {
                fileInput.files = files;
                showSelectedFiles(files);
            }
        });

        // Handle file input change
        fileInput.addEventListener('change', () => {
            if (fileInput.files.length) {
                showSelectedFiles(fileInput.files);
            }
        });
    }

    // SHOW SELECTED FILES
    function showSelectedFiles(files) {
        const container = document.getElementById('selectedFiles');
        const uploadActions = document.getElementById('uploadActions');

        if (!container) return;

        container.innerHTML = '';

        Array.from(files).forEach(file => {
            const item = document.createElement('div');
            item.className = 'selected-file-item';
            item.innerHTML = `
                <span class="selected-file-name">
                    ${getFileEmoji(file.type)} ${file.name}
                </span>
                <span class="selected-file-size">${formatSize(file.size)}</span>
            `;
            container.appendChild(item);
        });

        if (uploadActions) {
            uploadActions.style.display = 'flex';
        }

        const btnText = document.getElementById('uploadBtnText');
        if (btnText) {
            btnText.textContent = `Upload ${files.length} file${files.length > 1 ? 's' : ''}`;
        }
    }

    // FILE EMOJI
    function getFileEmoji(type) {
        if (!type) return '📁';
        if (type.startsWith('image/')) return '🖼️';
        if (type.startsWith('video/')) return '🎬';
        if (type.startsWith('audio/')) return '🎵';
        if (type === 'application/pdf') return '📕';
        if (type.includes('zip') || type.includes('rar') || type.includes('tar')) return '📦';
        if (type.includes('word') || type.includes('document')) return '📝';
        if (type.includes('sheet') || type.includes('excel')) return '📊';
        if (type.startsWith('text/')) return '📄';
        return '📁';
    }

    // FORMAT FILE SIZE
    function formatSize(bytes) {
        if (bytes < 1024) return `${bytes} B`;
        if (bytes < 1024 * 1024) return `${(bytes / 1024).toFixed(1)} KB`;
        if (bytes < 1024 ** 3) return `${(bytes / (1024 * 1024)).toFixed(1)} MB`;
        return `${(bytes / (1024 ** 3)).toFixed(1)} GB`;
    }

    // UPLOAD WITH PROGRESS
    if (uploadForm) {
        uploadForm.addEventListener('submit', (e) => {
            e.preventDefault();

            const files = fileInput.files;
            if (!files.length) return;

            const progressContainer = document.getElementById('progressContainer');
            const progressFill = document.getElementById('progressFill');
            const progressText = document.getElementById('progressText');
            const uploadBtn = document.getElementById('uploadBtn');
            const uploadActions = document.getElementById('uploadActions');

            // Show progress
            if (progressContainer) progressContainer.style.display = 'block';
            if (uploadActions) uploadActions.style.display = 'none';

            const formData = new FormData(uploadForm);
            const xhr = new XMLHttpRequest();

            // Progress tracking
            xhr.upload.addEventListener('progress', (e) => {
                if (e.lengthComputable) {
                    const pct = Math.round((e.loaded / e.total) * 100);
                    if (progressFill) progressFill.style.width = `${pct}%`;
                    if (progressText) progressText.textContent = `Uploading... ${pct}%`;
                }
            });

            // On complete
            xhr.addEventListener('load', () => {
                if (progressFill) progressFill.style.width = '100%';
                if (progressText) progressText.textContent = 'Upload complete! Redirecting...';
                setTimeout(() => {
                    window.location.href = '/gallery';
                }, 800);
            });

            // On error
            xhr.addEventListener('error', () => {
                if (progressText) progressText.textContent = 'Upload failed. Please try again.';
                if (uploadActions) uploadActions.style.display = 'flex';
                if (progressContainer) progressContainer.style.display = 'none';
            });

            xhr.open('POST', uploadForm.action);
            xhr.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
            xhr.send(formData);
        });
    }

    // AUTO DISMISS FLASH
    const flashes = document.querySelectorAll('.flash');
    flashes.forEach(flash => {
        setTimeout(() => {
            flash.style.opacity = '0';
            flash.style.transition = 'opacity 0.5s ease';
            setTimeout(() => flash.remove(), 500);
        }, 4000);
    });

});

// CLEAR FILES
function clearFiles() {
    const fileInput = document.getElementById('fileInput');
    const container = document.getElementById('selectedFiles');
    const uploadActions = document.getElementById('uploadActions');

    if (fileInput) fileInput.value = '';
    if (container) container.innerHTML = '';
    if (uploadActions) uploadActions.style.display = 'none';
}

// CONFIRM DELETE
function confirmDelete() {
    return confirm('Delete this file? This cannot be undone.');
}