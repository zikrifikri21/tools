#!/bin/bash

# Fungsi untuk membuat SSH key
create_ssh_key() {
    echo "Masukkan nama repository atau alias (misal: repo1 atau my-github-key):"
    read ALIAS

    echo "Masukkan email yang ingin dikaitkan dengan SSH key ini:"
    read EMAIL

    # Set lokasi penyimpanan key
    SSH_KEY_PATH="$HOME/.ssh/id_rsa_$ALIAS"

    # Membuat SSH key baru
    ssh-keygen -t rsa -b 4096 -C "$EMAIL" -f "$SSH_KEY_PATH" -N ""

    # Menambahkan konfigurasi ke file ~/.ssh/config
    CONFIG_ENTRY="
    # Konfigurasi untuk $ALIAS
    Host $ALIAS
      HostName github.com
      User git
      IdentityFile $SSH_KEY_PATH
    "

    echo "$CONFIG_ENTRY" >> ~/.ssh/config

    # Menambahkan key ke ssh-agent setelah konfigurasi selesai
    eval "$(ssh-agent -s)" > /dev/null
    ssh-add "$SSH_KEY_PATH"
    HIJAU="\033[032m"
    RT_W="\033[0m"
    # Menampilkan hasil dan instruksi selanjutnya
    echo "SSH key untuk $ALIAS berhasil dibuat dan dikonfigurasi!"
    echo "Key public:"
    cat "$SSH_KEY_PATH.pub"
    echo -e "\nJalankan Perintah ini agar bisa mengclone repo dari github menggunakan ssh key $HIJAU"
    echo -e "eval \"\$(ssh-agent -s)\""
    echo -e "ssh-add $SSH_KEY_PATH $RT_W"
    echo -e "\nTambahkan key ini ke akun GitHub Anda di https://github.com/settings/keys"
}

# Fungsi untuk menghapus SSH key dan konfigurasi
delete_ssh_key() {
    echo "Masukkan nama alias dari SSH key yang ingin dihapus:"
    read ALIAS

    # Lokasi key
    SSH_KEY_PATH="$HOME/.ssh/id_rsa_$ALIAS"

    # Hapus file key
    if [ -f "$SSH_KEY_PATH" ]; then
        rm "$SSH_KEY_PATH" "$SSH_KEY_PATH.pub"
        echo "SSH key $ALIAS telah dihapus dari sistem."
    else
        echo "SSH key $ALIAS tidak ditemukan."
    fi

    # Hapus konfigurasi dari ~/.ssh/config
    sed -i "/# Konfigurasi untuk $ALIAS/,/IdentityFile/d" ~/.ssh/config
    echo "Konfigurasi untuk $ALIAS telah dihapus dari ~/.ssh/config."
}

# Memilih antara membuat atau menghapus SSH key
echo "Pilih opsi:"
echo "1. Buat SSH key baru"
echo "2. Hapus SSH key"
read -p "Masukkan pilihan (1 atau 2): " choice

case $choice in
    1)
        create_ssh_key
        ;;
    2)
        delete_ssh_key
        ;;
    *)
        echo "Pilihan tidak valid. Silakan pilih 1 atau 2."
        ;;
esac
