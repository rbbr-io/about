document.addEventListener('DOMContentLoaded', function() {
    // Функция для установки случайного фрагмента изображения в качестве фона логотипа
    function setRandomBackgroundPosition() {
        const logoElement = document.querySelector('.logo');
        if (!logoElement) return;

        // Размеры оригинального изображения
        const imageWidth = 830;
        const imageHeight = 560;

        // Размеры видимой части (размер логотипа)
        const visibleWidth = 300;
        const visibleHeight = 120;

        // Вычисляем максимально возможные координаты
        const maxX = imageWidth - visibleWidth;
        const maxY = imageHeight - visibleHeight;

        // Генерируем случайные координаты
        const randomX = Math.floor(Math.random() * maxX);
        const randomY = Math.floor(Math.random() * maxY);

        // Устанавливаем position для фона
        logoElement.style.backgroundPosition = `-${randomX}px -${randomY}px`;

        // Показываем логотип с анимацией
        setTimeout(() => {
            logoElement.classList.add('animated');
        }, 300);
    }

    // Вызываем функцию при загрузке страницы
    setRandomBackgroundPosition();

    // Анимация появления секций при скролле
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('visible');
            }
        });
    }, {
        threshold: 0.1
    });

    document.querySelectorAll('section').forEach(section => {
        observer.observe(section);
    });

    // Ограничение выбора чекбоксов (максимум 2)
    const checkboxes = document.querySelectorAll('input[name="selected_guides"]');
    const selectionHint = document.querySelector('.selection-hint');
    const resourceForm = document.getElementById('resource-form');

    // Функция для обновления состояния чекбоксов
    const updateCheckboxStates = () => {
        const checkedCount = document.querySelectorAll('input[name="selected_guides"]:checked').length;

        // Обновляем подсказку
        selectionHint.textContent = `You selected ${checkedCount} of 2 guides`;
        selectionHint.style.color = "#667085";

        // Если выбрано 2 чекбокса, делаем остальные неактивными
        if (checkedCount >= 2) {
            checkboxes.forEach(cb => {
                if (!cb.checked) {
                    cb.disabled = true;
                    cb.parentNode.classList.add('disabled');
                }
            });
        } else {
            // Иначе делаем все чекбоксы активными
            checkboxes.forEach(cb => {
                cb.disabled = false;
                cb.parentNode.classList.remove('disabled');
            });
        }
    };

    // Инициализируем состояние при загрузке
    updateCheckboxStates();

    // Добавляем обработчики изменения для всех чекбоксов
    checkboxes.forEach(checkbox => {
        checkbox.addEventListener('change', updateCheckboxStates);
    });

    // Обработка отправки формы
    if (resourceForm) {
        resourceForm.addEventListener('submit', function(e) {
            e.preventDefault(); // Предотвращаем стандартную отправку формы

            const email = document.getElementById('email').value;
            const selectedGuides = Array.from(document.querySelectorAll('input[name="selected_guides"]:checked')).map(cb => cb.value);

            if (selectedGuides.length === 0) {
                selectionHint.textContent = "Please select at least 1 guide";
                selectionHint.style.color = "#e53e3e";
                return;
            }

            // Подготавливаем данные для отправки
            const formData = new FormData();
            formData.append('email', email);
            selectedGuides.forEach(guide => {
                formData.append('selected_guides[]', guide);
            });

            // Показываем индикатор загрузки
            const submitButton = resourceForm.querySelector('button[type="submit"]');
            const originalButtonText = submitButton.textContent;
            submitButton.disabled = true;
            submitButton.textContent = 'Sending...';

            // Отправляем данные через Sinatra-прокси
            fetch('/send-guides', {
                method: 'POST',
                body: formData
            })
            .then(response => {
                if (!response.ok) {
                    throw new Error('Network response was not ok');
                }
                return response.json();
            })
            .then(data => {
                console.log('Success:', data);
                // Показываем сообщение об успехе
                resourceForm.innerHTML = '<p class="success-message">Thank you! Your selected guides will be sent to your inbox shortly.</p>';
            })
            .catch(error => {
                console.error('Error:', error);
                // Возвращаем кнопку в исходное состояние
                submitButton.disabled = false;
                submitButton.textContent = originalButtonText;
                selectionHint.textContent = "There was a problem. Please try again.";
                selectionHint.style.color = "#e53e3e";
            });
        });
    }
});