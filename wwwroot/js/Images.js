
const input = document.getElementById("imageUpload");
const previewContainer = document.getElementById("previewContainer");
let allFiles = []; // store all selected files

input.addEventListener("change", () => {
    const newFiles = [...input.files];
allFiles = [...allFiles, ...newFiles]; // add new files to existing ones
renderPreviews();
});

function renderPreviews() {
    previewContainer.innerHTML = ""; // clear current previews

    allFiles.forEach((file, index) => {
        if (!file.type.startsWith("image/")) return;

const reader = new FileReader();
        reader.onload = (e) => {
            const col = document.createElement("div");
col.className = "position-relative";

col.innerHTML = `
<img src="${e.target.result}"
    class="img-thumbnail rounded shadow-sm"
    style="width: 120px; height: 120px; object-fit: cover;">
    <button type="button"
        class="btn btn-sm btn-danger position-absolute top-0 end-0 m-1 rounded-circle"
        title="Remove">&times;</button>
    `;

            // Remove file from list
            col.querySelector("button").addEventListener("click", () => {
        allFiles.splice(index, 1);
    updateInputFiles();
    renderPreviews();
            });

    previewContainer.appendChild(col);
        };
    reader.readAsDataURL(file);
    });

    updateInputFiles();
}

    function updateInputFiles() {
    const dataTransfer = new DataTransfer();
    allFiles.forEach(file => dataTransfer.items.add(file));
    input.files = dataTransfer.files;
}
