import { json } from '@sveltejs/kit';
import { env } from '$env/dynamic/private';

export async function POST({ request, cookies }) {
	const { message, edited_message } = await request.json();
    console.log('request', { message, edited_message })
    const TOKEN = env.TOKEN
    const ORIGIN = env.ORIGIN
    const msg = edited_message || message
    const text = msg && msg.text
    if ('/start' == text) {
        const chat_id = msg.chat && msg.chat.id
        const first_name = msg.chat && msg.chat.first_name
        const last_name = msg.chat && msg.chat.last_name
        const username = msg.chat && msg.chat.username

        let name = '';
        if (first_name) {
            name += first_name
        }
        if (last_name) {
            if (name) { name += ' ' }
            name += last_name
        }
        if (username) {
            if (name) { name += ' AKA ' }
            name += username
        }

        const buttonText = "MiniApp"
        const text = `Welcome, ${name}\nPress \"MiniApp\" button 👇 to open MiniApp`
        const reply_markup = { 
            inline_keyboard: [
                [
                    {
                        text: buttonText,
                        web_app: { url: ORIGIN },
                    }
                ]
            ]
        }

        fetch(`https://api.telegram.org/bot${TOKEN}/sendMessage`, { 
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({  
                chat_id,
                text, 
                reply_markup,
            })
        })

        fetch(`https://api.telegram.org/bot${TOKEN}/setChatMenuButton`, { 
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                chat_id,
                menu_button: {
                    type: "web_app",
                    text: buttonText,
                    web_app: { url: ORIGIN },
                },
            })
        })

        return json("OK", { status: 200 });
    } else {
        return json({ 'response': 'non /start' }, { status: 201 });
    }
}
