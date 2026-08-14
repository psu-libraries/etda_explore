function initializeDownloadModal() {
  document.addEventListener('show.bs.modal', function(e) {
    if (e.relatedTarget && e.relatedTarget.classList.contains('download-trigger')) {
      const filePath = e.relatedTarget.dataset.filePath;
      const downloadLink = document.getElementById('modalDownloadLink');
      downloadLink.href = filePath;

      downloadLink.onclick = function() {
        const modal = bootstrap.Modal.getInstance(e.target);
        if (modal) {
          modal.hide();
        }
      };
    }
  });
}

if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initializeDownloadModal);
} else {
  initializeDownloadModal();
}